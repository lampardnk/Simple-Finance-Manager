import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class CategoryData {
  final String date;
  final String category;
  final double amount;

  CategoryData(this.date, this.category, this.amount);
}

class CategoryWeeklyBar extends StatelessWidget {
  final List<Transaction> transactions;

  CategoryWeeklyBar(this.transactions);

  List<CategoryData> _getData() {
    List<CategoryData> data = [];
    var grouped = groupBy(transactions, (Transaction tx) => tx.date);
    grouped.forEach((date, transactions) {
      var byCategory = groupBy(transactions, (Transaction tx) => tx.category);
      byCategory.forEach((category, transactions) {
        var total = transactions.fold(0.0, (sum, tx) => sum + tx.amount);
        var formattedDate = DateFormat('dd/MM').format(date);
        data.add(CategoryData(formattedDate, category, total));
      });
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    var data = _getData();

    var seriesList = [
      charts.Series<CategoryData, String>(
        id: 'Food',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        data: data.where((d) => d.category == 'Food').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
      charts.Series<CategoryData, String>(
        id: 'Entertainment',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        data: data.where((d) => d.category == 'Entertainment').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
      charts.Series<CategoryData, String>(
        id: 'Healthcare',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        data: data.where((d) => d.category == 'Healthcare').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
      charts.Series<CategoryData, String>(
        id: 'Utilities',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        data: data.where((d) => d.category == 'Utilities').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
      charts.Series<CategoryData, String>(
        id: 'Shopping',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        data: data.where((d) => d.category == 'Shopping').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
      charts.Series<CategoryData, String>(
        id: 'Others',
        domainFn: (CategoryData sales, _) => sales.date,
        measureFn: (CategoryData sales, _) => sales.amount,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        data: data.where((d) => d.category == 'Others').toList(),
        labelAccessorFn: (CategoryData sales, _) => '${sales.amount}',
      ),
    ];

    double maxAmount = 0.0;
    for (var series in seriesList) {
      for (var data in series.data) {
        if (data.amount > maxAmount) {
          maxAmount = data.amount;
        }
      }
    }

    return charts.BarChart(
      seriesList,
      animate: false,
      barGroupingType: charts.BarGroupingType.stacked,
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 12, // size in Pts.
          ),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          [
            charts.TickSpec(0),
            charts.TickSpec(maxAmount * 0.5),
            charts.TickSpec(maxAmount * 1.0),
          ],
        ),
      ),
    );
  }
}
