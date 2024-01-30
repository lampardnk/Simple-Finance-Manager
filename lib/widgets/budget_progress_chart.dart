import 'package:first_app/models/budget.dart';
import 'package:first_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BudgetProgressBarChart extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;

  BudgetProgressBarChart({required this.budgets, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createSeries(),
      animate: true,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
              fontSize: 10, color: charts.MaterialPalette.black),
        ),
      ),
    );
  }

  List<charts.Series<ProgressData, String>> _createSeries() {
    List<ProgressData> data = [];

    var defaultKeys = [
      'Monthly',
      'Weekly',
      'Food',
      'Entertainment',
      'Healthcare',
      'Utilities',
      'Shopping',
      'Others'
    ];

    Map<String, double> budgetMap = {for (var b in budgets) b.type: b.amount};
    Map<String, double> transactionSumMap = {};

    DateTime now = DateTime.now();
    for (var transaction in transactions) {
      if (defaultKeys.contains(transaction.category)) {
        transactionSumMap.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }

      DateTime transactionDate = transaction.date;
      if (transactionDate.isAfter(now.subtract(Duration(days: 30)))) {
        transactionSumMap.update(
            'Monthly', (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
      if (transactionDate.isAfter(now.subtract(Duration(days: 7)))) {
        transactionSumMap.update(
            'Weekly', (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    for (var key in defaultKeys) {
      double budgetAmount = budgetMap[key] ?? 0;
      double transactionSum = transactionSumMap[key] ?? 0;

      double progressPercentage =
          (budgetAmount > 0) ? (transactionSum / budgetAmount * 100) : 0;
      double displayProgress = progressPercentage.clamp(0, 100);

      data.add(ProgressData(key, displayProgress,
          actualProgress: progressPercentage));
    }

    return [
      charts.Series<ProgressData, String>(
        id: 'Progress',
        domainFn: (ProgressData progress, _) => progress.category,
        measureFn: (ProgressData progress, _) => progress.progress,
        colorFn: (ProgressData progress, _) {
          return _getColorBasedOnProgress(progress.actualProgress);
        },
        data: data,
        labelAccessorFn: (ProgressData progress, _) =>
            '${progress.actualProgress.toStringAsFixed(0)}%',
      )
    ];
  }
}

charts.Color _getColorBasedOnProgress(double progress) {
  if (progress <= 30) {
    return charts.ColorUtil.fromDartColor(Colors.green);
  } else if (progress <= 65) {
    return charts.ColorUtil.fromDartColor(
        Color.lerp(Colors.green, Colors.yellow, (progress - 30) / 35)!);
  } else {
    return charts.ColorUtil.fromDartColor(
        Color.lerp(Colors.yellow, Colors.red, (progress - 65) / 35)!);
  }
}

class ProgressData {
  final String category;
  final double progress;
  final double actualProgress;

  ProgressData(this.category, this.progress, {required this.actualProgress});
}
