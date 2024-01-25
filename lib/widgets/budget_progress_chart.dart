import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BudgetProgressBarChart extends StatelessWidget {
  final Map<String, double> budgetProgress;

  BudgetProgressBarChart({required this.budgetProgress});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createSeries(),
      animate: true,
      vertical: false, // Horizontal bar chart
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
              fontSize: 10, // size in Pts.
              color: charts.MaterialPalette.black),
        ),
      ),
    );
  }

  List<charts.Series<ProgressData, String>> _createSeries() {
    List<ProgressData> data = [];

    // Ensure default columns are present
    var defaultKeys = [
      'Monthly',
      'Weekly',
      'Food',
      'Entertainment',
      'Healthcare',
      'Utilities',
      'Shopping',
      'Other'
    ];

    for (var key in defaultKeys) {
      double progressValue = budgetProgress[key] ?? 0;
      data.add(ProgressData(key, progressValue));
    }

    return [
      charts.Series<ProgressData, String>(
        id: 'Progress',
        domainFn: (ProgressData progress, _) => progress.category,
        measureFn: (ProgressData progress, _) => progress.progress,
        data: data,
        labelAccessorFn: (ProgressData progress, _) =>
            '${progress.progress.toStringAsFixed(0)}%',
      )
    ];
  }
}

class ProgressData {
  final String category;
  final double progress;

  ProgressData(this.category, this.progress);
}
