import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:isohel/pages/LinkingAccountsPage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:isohel/pages/HomeScaffold.dart';
import 'package:isohel/pages/LoginPage.dart';
import 'package:isohel/queries.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:isohel/pages/HomePage.dart';

void main() async {
  await initHiveForFlutter();
  Dio dio = new Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  final cookieJar = PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cookieJar));

  final Link _dioLink = DioLink(
    'http://109.152.210.59/api/graphql',
    client: dio,
  );

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: _dioLink,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  runApp(MyApp(client: client, dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;
  final String tempPath;
  final ValueNotifier<GraphQLClient> client;
  const MyApp({Key key, this.dio, this.tempPath, this.client})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: Query(
            options: QueryOptions(document: gql(me)),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.isLoading) {
                return CircularProgressIndicator();
              } else if (result.hasException) {
                print(result.exception);
                return MaterialApp(home: Text(result.exception.toString()));
              } else if (result.data['Me'] == null) {
                print(result.data);
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'ISOHEL FINANCE',
                    home: LoginPage());
              } else if (result.data['Me']['isMonzo'] == false ||
                  result.data['Me']['isAlpaca'] == false) {
                print(result.data);
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'ISOHEL FINANCE',
                    home: BiometricsPage(
                      needsLinking: true,
                    ));
              } else {
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'ISOHEL FINANCE',
                    home: BiometricsPage(
                      needsLinking: false,
                    ));
              }
            }));
  }
}

class BiometricsPage extends StatefulWidget {
  final bool needsLinking;
  BiometricsPage({Key key, this.needsLinking}) : super(key: key);

  @override
  _BiometricsPageState createState() => _BiometricsPageState();
}

class _BiometricsPageState extends State<BiometricsPage> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => authProcess());
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric is available!')
        : print('Biometric is unavailable.');

    return isAvailable;
  }

  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    print(listOfBiometrics);
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "authenticate to login",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated
        ? print('User is authenticated!')
        : print('User is not authenticated.');

    if (isAuthenticated) {
      if (widget.needsLinking) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => LinkingAccountsPage()));
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomeScaffold(),
          ),
        );
      }
    }
  }

  void authProcess() async {
    print(widget.needsLinking);
    if (await _isBiometricAvailable()) {
      await _getListOfBiometricTypes();
      await _authenticateUser();
    } else {
      if (widget.needsLinking) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => LinkingAccountsPage()));
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("we just need to verify who you are",
                  style: buildBlackHeader()),
              Container(
                height: 20,
              ),
              Image(image: AssetImage("lib/assets/logo.png"))
            ],
          )),
        ),
      ),
    );
  }
}
