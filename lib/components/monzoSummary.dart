import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:isohel/pages/HomePage.dart';
import 'package:isohel/pages/HomePage.dart';

import '../queries.dart';

class MonzoSummary extends StatelessWidget {
  const MonzoSummary({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var f = new NumberFormat.currency(locale: "en_US", symbol: "£");
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: Query(
          options: QueryOptions(document: gql(monzoComplete)),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.isLoading) {
              return CircularProgressIndicator();
            } else if (result.hasException) {
              print(result.exception);
              return Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "looks like we can't access your bank account. don't worry, you probably just need to refresh our access in your banking app. it's in your settings.",
                    style: buildBlackSubtextBigBold(),
                  ));
            } else if (result.data['error'] != null) {
              return Text("Please refresh our license in the Monzo app.");
            } else {
              var transactions =
                  result.data['monzoComplete']['transactions'][0];
              int tlength =
                  result.data['monzoComplete']['transactions'][0].length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                        ),
                        Container(
                          child: Image(
                              image: AssetImage("lib/assets/monzo-card.png")),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                spreadRadius: 15,
                                blurRadius: 12,
                                offset:
                                    Offset(0, 15), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              color: Color(0xff845af9),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text("balance",
                                  style: buildWhiteSubtextTinyBold()),
                              Text(
                                  "£" +
                                      (result.data['monzoComplete']['balances']
                                                  [0] /
                                              100)
                                          .toString(),
                                  style: buildWhiteSubtext()),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                                5,
                                (int index) => FlatButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                  padding: EdgeInsets.all(16),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text("description",
                                                              style:
                                                                  buildBalanceReadingModalKey()),
                                                          Spacer(),
                                                          Text(
                                                              transactions[tlength -
                                                                          index]
                                                                      [
                                                                      'description']
                                                                  .split(
                                                                      " ")[0],
                                                              style:
                                                                  buildBalanceReadingModal())
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("amount",
                                                              style:
                                                                  buildBalanceReadingModalKey()),
                                                          Spacer(),
                                                          Text(
                                                              f
                                                                  .format(transactions[tlength -
                                                                              index]
                                                                          [
                                                                          'amount'] /
                                                                      100)
                                                                  .toString(),
                                                              style:
                                                                  buildBalanceReadingModal())
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("created",
                                                              style:
                                                                  buildBalanceReadingModalKey()),
                                                          Spacer(),
                                                          Text(
                                                              DateTime.parse(transactions[
                                                                          tlength -
                                                                              index]
                                                                      [
                                                                      'created'])
                                                                  .toLocal()
                                                                  .toString(),
                                                              style:
                                                                  buildBalanceReadingModal())
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("currency",
                                                              style:
                                                                  buildBalanceReadingModalKey()),
                                                          Spacer(),
                                                          Text(
                                                              transactions[
                                                                      tlength -
                                                                          index]
                                                                  ['currency'],
                                                              style:
                                                                  buildBalanceReadingModal())
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text("category",
                                                              style:
                                                                  buildBalanceReadingModalKey()),
                                                          Spacer(),
                                                          Text(
                                                              transactions[
                                                                      tlength -
                                                                          index]
                                                                  ['category'],
                                                              style:
                                                                  buildBalanceReadingModal())
                                                        ],
                                                      ),
                                                    ],
                                                  ));
                                            });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10))),
                                        child: Row(
                                          children: [
                                            Text(
                                              (transactions[tlength - index]
                                                              ['description']
                                                          .toString()
                                                          .split(" ")[0]
                                                          .length <
                                                      15)
                                                  ? transactions[tlength - index]
                                                          ['description']
                                                      .toString()
                                                      .split(" ")[0]
                                                  : transactions[tlength -
                                                          index]['description']
                                                      .toString()
                                                      .split(" ")[0]
                                                      .replaceRange(
                                                          15,
                                                          transactions[tlength -
                                                                      index][
                                                                  'description']
                                                              .toString()
                                                              .split(" ")[0]
                                                              .length,
                                                          '...'),
                                              style: buildBalanceReading(),
                                            ),
                                            Spacer(),
                                            Text(
                                              f
                                                  .format(transactions[tlength -
                                                          index]['amount'] /
                                                      100)
                                                  .toString(),
                                              style: (transactions[tlength -
                                                              index]['amount']
                                                          .toString()[0] !=
                                                      '-')
                                                  ? buildWhiteBalanceReadingPositive()
                                                  : buildWhiteBalanceReadingNegative(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
