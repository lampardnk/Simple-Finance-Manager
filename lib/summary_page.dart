import 'package:flutter/material.dart';
import 'package:first_app/models/transaction.dart';

import 'keys.dart';

import 'widgets/transaction_list.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/sort_menu_button.dart';

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

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = _categoryTotal(transactions);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SummaryHeader(
            minHeight: MediaQuery.of(context).size.width / 2,
            maxHeight: MediaQuery.of(context).size.width / 2,
            child: Stack(
              children: [
                //category_pie_chart
                Positioned(
                  top: 0,
                  left: 0,
                  child: CategoryPieChart(categoryTotals: categoryTotals),
                ),
                //List of transactions
                Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  left: MediaQuery.of(context).size.width / 2.5 + 90,
                  child: TransactionList(transactions, _currentPage,
                      homePageKey.currentState!.editTransaction),
                ),
                //Pagination buttons
                Positioned(
                  top: MediaQuery.of(context).size.width / 2.5 + 40,
                  left: MediaQuery.of(context).size.width / 2.5 + 90,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'Left',
                        onPressed: () {
                          if (_currentPage > 0) {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        heroTag: 'Right',
                        onPressed: () {
                          if ((_currentPage + 1) * 6 < transactions.length) {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        },
                        child: Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
                //Total
                Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width / 2.5 + 90,
                  child: Text(
                    'Total: \$${transactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //sort_menu_button
                Positioned(
                  top: 0,
                  right: 0,
                  child: SortMenuButton(
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
