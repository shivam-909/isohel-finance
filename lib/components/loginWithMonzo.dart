import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:isohel/queries.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginWithMonzo extends StatelessWidget {
  final String userState;
  const LoginWithMonzo({Key key, this.userState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _launchURL(String monzourl) async {
      var url = monzourl;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Query(
        options: QueryOptions(document: gql(getMonzoLink)),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          return Center(
            child: FlatButton(
              child: Text("Login with Monzo"),
              onPressed: () => _launchURL(result.data['getMonzoRedirect']),
            ),
          );
        });
  }
}
