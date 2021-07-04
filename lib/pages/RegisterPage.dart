import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:isohel/queries.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Mutation(
        options: MutationOptions(
          document: gql(register),
          onCompleted: (data) =>
              {if (data["register"]["error"].length == 0) {}},
        ),
        builder: null);
  }
}
