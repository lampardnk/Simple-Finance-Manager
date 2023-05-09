import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:first_app/models/transaction.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  final List<Transaction> transactions;
  SummaryPage(this.transactions);
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Transaction> get transactions => widget.transactions;
  Map<String, double> _categoryTotal(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};

    for (Transaction transaction in transactions) {
      if (!categoryTotals.containsKey(transaction.category)) {
        categoryTotals[transaction.category] = 0;
      }
      categoryTotals[transaction.category] =
          categoryTotals[transaction.category]! + transaction.amount;
    }

    return categoryTotals;
  }

  void _sortByName() {
    setState(() {
      transactions.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void _sortByCategory() {
    setState(() {
      transactions.sort((a, b) => a.category.compareTo(b.category));
    });
  }

  void _sortByDate({required bool ascending}) {
    setState(() {
      transactions.sort((a, b) =>
          ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    });
  }

  void _sortByAmount({required bool ascending}) {
    setState(() {
      transactions.sort((a, b) => ascending
          ? a.amount.compareTo(b.amount)
          : b.amount.compareTo(a.amount));
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = _categoryTotal(transactions);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SummaryHeader(
            minHeight: MediaQuery.of(context).size.width / 2.5,
            maxHeight: MediaQuery.of(context).size.width / 2.5,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.width / 2.5,
                    child: categoryTotals.isNotEmpty
                        ? PieChart(
                            dataMap: categoryTotals,
                            animationDuration: Duration(milliseconds: 800),
                            chartRadius:
                                MediaQuery.of(context).size.width / 3.2,
                            colorList: [
                              Colors.red,
                              Colors.green,
                              Colors.blue,
                              Colors.yellow,
                              Colors.orange,
                            ],
                            initialAngleInDegree: 0,
                            chartType: ChartType.disc,
                            ringStrokeWidth: 32,
                            centerText: "Categories",
                            legendOptions: LegendOptions(
                              showLegendsInRow: false,
                              legendPosition: LegendPosition.right,
                              showLegends: true,
                              legendTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
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
                  ),
                ),
                Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width / 2.5 + 20,
                  child: Text(
                    'Total: \$${transactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    onSelected: (String value) {
                      switch (value) {
                        case 'Name':
                          _sortByName();
                          break;
                        case 'Category':
                          _sortByCategory();
                          break;
                        case 'Date Ascending':
                          _sortByDate(ascending: true);
                          break;
                        case 'Date Descending':
                          _sortByDate(ascending: false);
                          break;
                        case 'Amount Ascending':
                          _sortByAmount(ascending: true);
                          break;
                        case 'Amount Descending':
                          _sortByAmount(ascending: false);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'Name',
                          child: Text('Sort by Name'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Category',
                          child: Text('Sort by Category'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Date Ascending',
                          child: Text('Sort by Date (Ascending)'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Date Descending',
                          child: Text('Sort by Date (Descending)'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Amount Ascending',
                          child: Text('Sort by Amount (Ascending)'),
                        ),
                        PopupMenuItem<String>(
                          value: 'Amount Descending',
                          child: Text('Sort by Amount (Descending)'),
                        ),
                      ];
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  left: MediaQuery.of(context).size.width / 2.5 + 20,
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        // MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom - // Add this line
                        140,
                    width: MediaQuery.of(context).size.width / 2,
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  transactions[index].title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  transactions[index].category,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat.yMMMd()
                                      .format(transactions[index].date),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '\$${transactions[index].amount.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SummaryHeader extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SummaryHeader({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
