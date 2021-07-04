import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:isohel/components/newsFeed.dart';
import 'package:isohel/constants.dart';
import 'package:isohel/queries.dart';
import 'package:isohel/pages/HomePage.dart';

class StocksPage extends StatefulWidget {
  StocksPage({Key key}) : super(key: key);

  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final pageController = PageController(initialPage: 0);
  var page = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Row(children: [
                Text("Dashboard",
                    style: (page == 0)
                        ? buildBlackSubtextTinyBold()
                        : buildBlackSubtextTiny()),
                Spacer(),
                Text("Order",
                    style: (page == 1)
                        ? buildBlackSubtextTinyBold()
                        : buildBlackSubtextTiny()),
              ])),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [PortfolioPage(), BuyingSharesPage()],
              onPageChanged: (value) => {
                setState(() {
                  page = value;
                }),
                print(page)
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with TickerProviderStateMixin {
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
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ));
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
                children: [AlpacaAccount(), NewsFeedComponent()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BuyingSharesPage extends StatefulWidget {
  BuyingSharesPage({Key key}) : super(key: key);

  @override
  _BuyingSharesPageState createState() => _BuyingSharesPageState();
}

class _BuyingSharesPageState extends State<BuyingSharesPage> {
  TextEditingController tickerController = new TextEditingController();
  List assetData = [];
  String filter;
  @override
  void initState() {
    super.initState();
    //fill countries with objects
    tickerController.addListener(() {
      setState(() {
        filter = tickerController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    tickerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalPurchase();
  }
}

class SearchResultsBox extends StatefulWidget {
  SearchResultsBox({Key key, @required this.assetData}) : super(key: key);
  final List assetData;
  @override
  _SearchResultsBoxState createState() => _SearchResultsBoxState();
}

class _SearchResultsBoxState extends State<SearchResultsBox> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
              itemCount: widget.assetData.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: FlatButton(
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return ModalPurchase();
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: new Text(
                        widget.assetData[index]['name'],
                        style: buildBlackSubtext(),
                      ),
                    ),
                  ),
                );
              }),
        ));
  }

  void _scrollListener() {
    print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 500) {
      setState(() {
        widget.assetData
            .addAll(new List.generate(42, (index) => 'Inserted $index'));
      });
    }
  }
}

class ModalPurchase extends StatelessWidget {
  const ModalPurchase({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [BuySharesForm()],
      ),
    );
  }
}

class BuySharesForm extends StatefulWidget {
  BuySharesForm({Key key}) : super(key: key);

  @override
  _BuySharesFormState createState() => _BuySharesFormState();
}

class _BuySharesFormState extends State<BuySharesForm> {
  TextEditingController _controller;
  TextEditingController ticker;
  TextEditingController limitController;
  TextEditingController stopController;
  TextEditingController trailController;
  TextEditingController trailPController;
  var response;
  String sideValue = 'buy';
  String typeValue = 'market';
  String timeValue = 'day';

  void initState() {
    super.initState();
    _controller = TextEditingController();
    ticker = TextEditingController();
    limitController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    ticker.dispose();
    limitController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
          document: gql(placeOrder),
          update: (GraphQLDataProxy cache, QueryResult result) {
            return cache;
          },
          onCompleted: (dynamic resultData) {
            print(resultData);
            if (resultData != null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Order information"),
                        content: (resultData['placeOrder']['failed_at'] == null)
                            ? Text("Order placed: " +
                                resultData['placeOrder']['side'].toString() +
                                " " +
                                resultData['placeOrder']['qty'].toString() +
                                " " +
                                resultData['placeOrder']['symbol'].toString())
                            : Text("Order failed."),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Okay"))
                        ]);
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("Order failed"),
                        content: Text("Order did not go through."),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Okay"))
                        ]);
                  });
            }
          },
          onError: (dynamic e) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text("Order failed"),
                      content: Text(e.toString()),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Okay"))
                      ]);
                });
          }),
      builder: (RunMutation runMutation, QueryResult result) {
        return Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: ticker,
                  decoration: InputDecoration(
                    labelText: 'ticker',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'quantity',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: DropdownButton<String>(
                            value: sideValue,
                            items: <String>['buy', 'sell']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              sideValue = newValue;
                              setState(() {
                                sideValue;
                              });
                            }),
                      ),
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: DropdownButton<String>(
                            value: timeValue,
                            items: <String>[
                              'day',
                              'gtc',
                              'opg',
                              'cls',
                              'ioc',
                              'foc'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              timeValue = newValue;
                              setState(() {
                                timeValue;
                              });
                            }),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: DropdownButton<String>(
                            value: typeValue,
                            items: <String>[
                              'market',
                              'limit',
                              'stop',
                              'stop_limit',
                              'trailing_stop'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              typeValue = newValue;
                              setState(() {
                                typeValue;
                              });
                            }),
                      ),
                    ]),
                    (() {
                      if (typeValue == 'limit') {
                        return TableRow(children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              controller: limitController,
                              decoration: InputDecoration(
                                labelText: 'limit price',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          Spacer()
                        ]);
                      } else if (typeValue == 'stop_limit') {
                        return TableRow(children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              controller: limitController,
                              decoration: InputDecoration(
                                labelText: 'limit price',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              controller: stopController,
                              decoration: InputDecoration(
                                labelText: 'stop price',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ]);
                      } else if (typeValue == 'stop') {
                        return TableRow(children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              controller: stopController,
                              decoration: InputDecoration(
                                labelText: 'stop price',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          Spacer()
                        ]);
                      } else {
                        return TableRow(children: [Container(), Container()]);
                      }
                    }())
                  ],
                ),
              ),
              FlatButton(
                  padding: EdgeInsets.all(8),
                  color: Color(0xff845af9),
                  onPressed: () {
                    try {
                      runMutation({
                        "options": {
                          "symbol": ticker.text,
                          "qty": _controller.text,
                          "side": sideValue,
                          "type": typeValue,
                          "time_in_force": timeValue
                        }
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text(
                    "send order",
                    style: buildWhiteSubtextTinyBold(),
                  )),
            ],
          ),
        );
      },
    );
  }
}
