import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:isohel/pages/HomePage.dart';
import 'HomeScaffold.dart';

import '../queries.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Mutation(
        options: MutationOptions(
          document: gql(login),
          update: (GraphQLDataProxy cache, QueryResult result) {
            return cache;
          },
          onCompleted: (dynamic resultData) {
            try {
              if (resultData['login']['user']['username'] != "null") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScaffold()),
                );
              }
            } catch (e) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Invalid input"),
                      content: Text(
                          "Username must be greater than 3 characters, and the password greater than 6."),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Okay"))
                      ],
                    );
                  });
            }
          },
        ),
        builder: (
          RunMutation runMutation,
          QueryResult result,
        ) {
          return Scaffold(
              body: SafeArea(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Image(
                    image: AssetImage("lib/assets/logo.png"),
                    height: 300,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  TextField(
                    controller: usernameController,
                  ),
                  Container(
                    height: 20,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                  ),
                  Container(
                    height: 20,
                  ),
                  FlatButton(
                      onPressed: () => runMutation({
                            "usernameOrEmail": usernameController.text,
                            "password": passwordController.text
                          }),
                      child: Text("register"))
                ],
              ),
            ),
          ));
        });
  }
}
