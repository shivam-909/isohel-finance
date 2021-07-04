import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../queries.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkingAccountsPage extends StatefulWidget {
  LinkingAccountsPage({Key key}) : super(key: key);

  @override
  _LinkingAccountsPageState createState() => _LinkingAccountsPageState();
}

class _LinkingAccountsPageState extends State<LinkingAccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Mutation(
                options: MutationOptions(
                  document: gql(getMonzoRedirect),
                  update: (GraphQLDataProxy cache, QueryResult result) {
                    return cache;
                  },
                  onError: (dynamic error) {
                    print(error);
                  },
                ),
                builder: (
                  RunMutation runMutation,
                  QueryResult result,
                ) {
                  if (result.hasException) {
                    print(result.exception);
                  }

                  return TextButton(
                    child: Text("login with monzo"),
                    onPressed: () {
                      runMutation({});
                      if (result.isLoading) {
                        _showDialog();
                      } else {
                        var url = result.data['getMonzoRedirect'];
                        _launchURL(url);
                      }
                    },
                  );
                }),
            Container(
              height: 20,
            ),
            Mutation(
                options: MutationOptions(
                  document: gql(getAlpacaRedirect),
                  update: (GraphQLDataProxy cache, QueryResult result) {
                    return cache;
                  },
                ),
                builder: (
                  RunMutation runMutation,
                  QueryResult result,
                ) {
                  return TextButton(
                    child: Text("login with alpaca"),
                    onPressed: () {
                      runMutation({});
                      if (result.isLoading) {
                        _showDialog();
                      } else {
                        var url = result.data['getAlpacaRedirect'];
                        _launchURL(url);
                      }
                    },
                  );
                }),
          ],
        ),
      ),
    ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("sending you there..."),
            content: CircularProgressIndicator(),
          );
        });
  }
}
