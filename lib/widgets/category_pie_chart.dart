import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  CategoryPieChart({required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 2.5,
      child: categoryTotals.isNotEmpty
          ? PieChart(
              dataMap: categoryTotals,
              animationDuration: Duration(milliseconds: 800),
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
              ],
              initialAngleInDegree: 0,
              chartType: ChartType.disc,
              ringStrokeWidth: 32,
              centerText: "Categories",
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: false,
              ),
            )
          : Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
