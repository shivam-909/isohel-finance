import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:isohel/components/monzoSummary.dart';
import 'package:isohel/components/portfolioChart.dart';
import 'package:isohel/queries.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller..reverse();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MonzoSummary(),
                  Container(
                    height: 20,
                  ),
                  AlpacaAccount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlpacaPortfolio extends StatelessWidget {
  const AlpacaPortfolio({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var f = new NumberFormat.currency(locale: "en_US", symbol: "\$");
    var percent = new NumberFormat.decimalPercentPattern(decimalDigits: 2);
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Query(
        options: QueryOptions(document: gql(alpacaPositions)),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.isLoading) {
            return CircularProgressIndicator();
          } else if (result
                  .data['getAlpacaPositionsPaper']['response'].length ==
              0) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Text(
                  "you don't have any stocks. you should probably go buy some.",
                  style: buildGreyHeader()),
            );
          } else {
            return DataTable(
              columns: [
                DataColumn(label: Text('symbol')),
                DataColumn(label: Text('price')),
                DataColumn(label: Text('change')),
                DataColumn(label: Text("quantity"))
              ],
              rows: List.generate(
                result.data['getAlpacaPositionsPaper']['response'].length,
                (index) => DataRow(
                  cells: [
                    DataCell(
                      Text(result.data['getAlpacaPositionsPaper']['response']
                          [index]["symbol"]),
                    ),
                    DataCell(
                      Text(f.format(double.parse(
                          result.data['getAlpacaPositionsPaper']['response']
                              [index]["current_price"]))),
                    ),
                    DataCell(
                      Text(percent.format(double.parse(
                          result.data['getAlpacaPositionsPaper']['response']
                              [index]["change_today"]))),
                    ),
                    DataCell(
                      Text((result.data['getAlpacaPositionsPaper']['response']
                          [index]["qty"])),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AlpacaAccount extends StatelessWidget {
  const AlpacaAccount({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var f = new NumberFormat.currency(locale: "en_US", symbol: "\$");
    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: Query(
            options: QueryOptions(document: gql(alpacaSummary)),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.isLoading) {
                return CircularProgressIndicator();
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xff845af9),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'portfolio value:',
                                      style: buildWhiteSubtextTinyBold(),
                                    ),
                                    Text(
                                      f
                                          .format(double.parse(result
                                                  .data['getAlpacaAccountPaper']
                                              ["portfolio_value"]))
                                          .toString(),
                                      style: buildWhiteSubtextPortfolio(),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      'cash balance:',
                                      style: buildWhiteSubtextTinyBold(),
                                    ),
                                    Text(
                                      f
                                          .format(double.parse(result
                                                  .data['getAlpacaAccountPaper']
                                              ["cash"]))
                                          .toString(),
                                      style: buildWhiteSubtextPortfolio(),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Text(
                                      'buying power:',
                                      style: buildWhiteSubtextTinyBold(),
                                    ),
                                    Text(
                                      f
                                          .format(double.parse(result
                                                  .data['getAlpacaAccountPaper']
                                              ["buying_power"]))
                                          .toString(),
                                      style: buildWhiteSubtextPortfolio(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PortfolioChart(),
                          AlpacaPortfolio()
                        ],
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}

TextStyle buildBlackSubtext() {
  return TextStyle(
      color: Colors.black, fontSize: 20, fontWeight: FontWeight.w200);
}

TextStyle buildWhiteSubtextPortfolio() {
  return TextStyle(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300);
}

TextStyle buildWhiteSubtext() {
  return TextStyle(
      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w200);
}

TextStyle buildBalanceReading() {
  return TextStyle(
      color: Color(0xff837e8d), fontSize: 16, fontWeight: FontWeight.bold);
}

TextStyle buildBalanceReadingModalKey() {
  return TextStyle(
      color: Color(0xff845af9), fontSize: 20, fontWeight: FontWeight.bold);
}

TextStyle buildBalanceReadingModal() {
  return TextStyle(
      color: Color(0xff837e8d), fontSize: 20, fontWeight: FontWeight.bold);
}

TextStyle buildWhiteBalanceReadingNegative() {
  return TextStyle(
      color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold);
}

TextStyle buildWhiteBalanceReadingPositive() {
  return TextStyle(
      color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold);
}

TextStyle buildBlackSubtextTinyBold() {
  return TextStyle(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
}

TextStyle buildBlackSubtextTiny() {
  return TextStyle(color: Colors.black, fontSize: 12);
}

TextStyle buildBlackSubtextBigBold() {
  return TextStyle(
      color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold);
}

TextStyle buildWhiteSubtextTinyBold() {
  return TextStyle(
      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
}

TextStyle buildWhiteRegular() {
  return TextStyle(
      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300);
}

TextStyle buildBlackRegular() {
  return TextStyle(
      color: Colors.black, fontSize: 22, fontWeight: FontWeight.w300);
}

TextStyle buildWhiteHeader() {
  return TextStyle(
      color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold);
}

TextStyle buildBlackHeader() {
  return TextStyle(
      color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold);
}

TextStyle buildGreyHeader() {
  return TextStyle(
      color: Colors.black26, fontSize: 26, fontWeight: FontWeight.bold);
}

TextStyle buildPurpleHeader() {
  return TextStyle(
      color: Color(0xff845af9), fontSize: 30, fontWeight: FontWeight.bold);
}
