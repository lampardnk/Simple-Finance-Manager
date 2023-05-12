import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  CategoryPieChart({required this.categoryTotals});

  final Map<String, Color> categoryColors = {
    'Food': Colors.red,
    'Entertainment': Colors.green,
    'Healthcare': Colors.blue,
    'Utilities': Colors.yellow,
    'Shopping': Colors.orange,
    'Others': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 2.5 - 250,
      child: categoryTotals.isNotEmpty
          ? PieChart(
              dataMap: categoryTotals,
              animationDuration: Duration(milliseconds: 800),
              chartRadius: MediaQuery.of(context).size.width / 3.2 - 150,
              colorList: categoryTotals.keys
                  .map((key) => categoryColors[key] ?? Colors.grey)
                  .toList(),
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
