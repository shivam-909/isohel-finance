import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import '../queries.dart';

class PortfolioChart extends StatefulWidget {
  PortfolioChart({Key key}) : super(key: key);

  @override
  _PortfolioChartState createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart> {
  @override
  Widget build(BuildContext context) {
    var f = new NumberFormat("0.0#", "en_US");
    return Query(
      options: QueryOptions(document: gql(portfolioChart)),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.isLoading) {
          return CircularProgressIndicator();
        } else {
          return ChartStructure(data: result.data);
        }
      },
    );
  }
}

class ChartStructure extends StatefulWidget {
  final Map<String, dynamic> data;
  const ChartStructure({Key key, this.data}) : super(key: key);
  @override
  _ChartStructureState createState() => _ChartStructureState();
}

class _ChartStructureState extends State<ChartStructure> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Colors.transparent),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.transparent,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: false,
        ),
        leftTitles: SideTitles(
          interval:
              widget.data['getPortfolioHistoryPaper']['interval'].toDouble(),
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 8,
          ),
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: widget.data['getPortfolioHistoryPaper']['minX'].toDouble(),
      maxX: widget.data['getPortfolioHistoryPaper']['maxX'].toDouble(),
      minY: widget.data['getPortfolioHistoryPaper']['minY'].toDouble(),
      maxY: widget.data['getPortfolioHistoryPaper']['maxY'].toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
              widget.data['getPortfolioHistoryPaper']['response'].length,
              (index) => FlSpot(
                  double.parse(widget.data['getPortfolioHistoryPaper']
                          ['response'][index][0]
                      .toString()),
                  double.parse(widget.data['getPortfolioHistoryPaper']
                          ['response'][index][1]
                      .toString()))),
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
