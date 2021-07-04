import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:isohel/pages/HomePage.dart';
import 'package:isohel/queries.dart';

class NewsFeedComponent extends StatefulWidget {
  NewsFeedComponent({Key key}) : super(key: key);

  @override
  _NewsFeedComponentState createState() => _NewsFeedComponentState();
}

class _NewsFeedComponentState extends State<NewsFeedComponent> {
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(document: gql(stocksNews)),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            print(result.exception);
            return Text(result.exception.toString());
          } else if (result.isLoading) {
            return CircularProgressIndicator();
          } else {
            var newsData = result.data['stocksNews']['response'];
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 10,
                  ),
                  Column(
                    children: List.generate(
                        newsData.length,
                        (index) => Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: Color(0xff845af9)),
                                      child: Text(
                                          newsData[index]['title'].toString(),
                                          style: buildWhiteHeader()),
                                    ),
                                    Container(
                                      height: 20,
                                    ),
                                    (newsData[index]['description'] != null)
                                        ? Text(
                                            newsData[index]['description'],
                                            style: buildBlackRegular(),
                                          )
                                        : Text("No description provided"),
                                    Container(
                                      height: 20,
                                    ),
                                    (() {
                                      if (newsData[index]['content'] != null) {
                                        if (newsData[index]['content']
                                            .contains("[")) {
                                          return Text(
                                              newsData[index]['content']
                                                  .toString()
                                                  .replaceRange(
                                                      newsData[index]['content']
                                                          .toString()
                                                          .indexOf("["),
                                                      newsData[index]['content']
                                                          .length,
                                                      ""),
                                              style: buildBlackSubtext());
                                        } else {
                                          return Text(
                                              newsData[index]['content']
                                                  .toString(),
                                              style: buildBlackSubtext());
                                        }
                                      } else {
                                        return Text("");
                                      }
                                    }()),
                                    Container(
                                      height: 20,
                                    ),
                                    (() {
                                      if (newsData[index]['urlToImage'] !=
                                          null) {
                                        return Image.network(
                                            newsData[index]['urlToImage']);
                                      } else {
                                        return Text("");
                                      }
                                    }())
                                  ],
                                ),
                              ),
                            )),
                  ),
                ],
              ),
            );
          }
        });
  }
}
