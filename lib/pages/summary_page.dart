import 'package:first_app/models/budget.dart';
import 'package:first_app/widgets/budget_progress_chart.dart';
import 'package:flutter/material.dart';
import 'package:first_app/models/transaction.dart';
import '../keys.dart';
import '../widgets/transaction_list.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/sort_menu_button.dart';
import '../widgets/filter_button.dart';

bool filtered = false;

class SummaryPage extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Budget> budgets;

  SummaryPage(this.transactions, this.budgets);
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Transaction> get transactions => widget.transactions;
  List<Budget> get budgets => widget.budgets;
  List<Transaction> filteredTransactions = [];
  List<String> categoriesList = [
    'Food',
    'Entertainment',
    'Healthcare',
    'Utilities',
    'Shopping',
    'Others',
  ];
  List<String> exceededCategories = [];

  void _handleFilter(List<FilterOption> selectedOptions) {
    List<String> selectedFilters = selectedOptions
        .where((option) => option.isSelected)
        .map((option) => option.name)
        .toList();

    DateTime now = DateTime.now();

    filteredTransactions = transactions;

    if (selectedFilters.contains('All')) {
      return;
    }

    if (selectedFilters.contains('From last 7 days')) {
      DateTime oneWeekAgo = now.subtract(Duration(days: 7));
      filteredTransactions = filteredTransactions
          .where((tx) => tx.date.isAfter(oneWeekAgo))
          .toList();
    }

    if (selectedFilters.contains('From last 30 days')) {
      DateTime oneMonthAgo = now.subtract(Duration(days: 30));
      filteredTransactions = filteredTransactions
          .where((tx) => tx.date.isAfter(oneMonthAgo))
          .toList();
    }

    if (selectedFilters.contains('Under \$30')) {
      filteredTransactions =
          filteredTransactions.where((tx) => tx.amount < 30.0).toList();
    }

    if (selectedFilters.contains('Above \$30')) {
      filteredTransactions =
          filteredTransactions.where((tx) => tx.amount > 30.0).toList();
    }

    List<String> categories = selectedFilters
        .where((filter) => categoriesList.contains(filter))
        .toList();
    if (categories.isNotEmpty) {
      filteredTransactions = filteredTransactions
          .where((tx) => categories.contains(tx.category))
          .toList();
    }

    filtered = true;
    setState(() {});
    print("Filter applied");
  }

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
      filteredTransactions.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void _sortByCategory() {
    setState(() {
      filteredTransactions.sort((a, b) => a.category.compareTo(b.category));
    });
  }

  void _sortByDate({required bool ascending}) {
    setState(() {
      filteredTransactions.sort((a, b) =>
          ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    });
  }

  void _sortByAmount({required bool ascending}) {
    setState(() {
      filteredTransactions.sort((a, b) => ascending
          ? a.amount.compareTo(b.amount)
          : b.amount.compareTo(a.amount));
    });
  }

  int _currentPage = 0;
  int _pageLength = 10;

  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;

  double top_padding = 15;
  double bottom_padding = 15;
  double left_padding = 30;
  double right_padding = 0;

  List<FilterOption> filterOptions = [
    FilterOption(name: 'All'),
    FilterOption(name: 'From last 7 days'),
    FilterOption(name: 'From last 30 days'),
    FilterOption(name: 'Under \$30'),
    FilterOption(name: 'Above \$30'),
    FilterOption(name: 'Food'),
    FilterOption(name: 'Entertainment'),
    FilterOption(name: 'Healthcare'),
    FilterOption(name: 'Utilities'),
    FilterOption(name: 'Shopping'),
    FilterOption(name: 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    if (filtered != true) {
      filteredTransactions = transactions;
    }

    Map<String, double> categoryTotals = _categoryTotal(filteredTransactions);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SummaryHeader(
            minHeight: MediaQuery.of(context).size.width / 2,
            maxHeight: MediaQuery.of(context).size.width / 2,
            child: Stack(
              children: [
                //Pie chart
                Positioned(
                  top: top_padding,
                  left: left_padding + 75,
                  child: CategoryPieChart(categoryTotals: categoryTotals),
                ),
                //Budget progress bar chart
                Positioned(
                  top: MediaQuery.of(context).size.width / 4,
                  left: left_padding + 75,
                  child: SizedBox(
                    width: 600,
                    height: 400,
                    child: BudgetProgressBarChart(
                      budgets: budgets,
                      transactions: transactions,
                    ),
                  ),
                ),
                //List of transactions
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80 + top_padding,
                  left: MediaQuery.of(context).size.width / 2.5 +
                      90 +
                      left_padding,
                  child: TransactionList(
                      filteredTransactions,
                      _currentPage,
                      _pageLength,
                      homePageKey.currentState!.editTransaction,
                      homePageKey.currentState!.deleteTransaction),
                ),
                //Pagination buttons
                Positioned(
                  top: MediaQuery.of(context).size.width / 2.5 -
                      40 +
                      top_padding,
                  left: MediaQuery.of(context).size.width / 2.5 +
                      90 +
                      left_padding,
                  child: Row(
                    children: [
                      AnimatedContainer(
                        height: 60,
                        width: 60,
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color:
                              _isHoveringLeft ? Colors.green[400] : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onHover: (value) {
                            setState(() {
                              _isHoveringLeft = value;
                            });
                          },
                          onTap: () {
                            if (_currentPage > 0) {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      AnimatedContainer(
                        height: 60,
                        width: 60,
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _isHoveringRight
                              ? Colors.green[400]
                              : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onHover: (value) {
                            setState(() {
                              _isHoveringRight = value;
                            });
                          },
                          onTap: () {
                            if ((_currentPage + 1) * _pageLength <
                                filteredTransactions.length) {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          },
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Total
                Positioned(
                  top: 40 + top_padding,
                  left: MediaQuery.of(context).size.width / 2.5 +
                      90 +
                      left_padding,
                  child: Text(
                    'Total: \$${filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)} (${filteredTransactions.length} Transactions)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Sort menu
                Positioned(
                  top: 35 + top_padding,
                  right: 45 + right_padding,
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
                //Filter menu
                Positioned(
                    top: 35 + top_padding,
                    right: 75 + right_padding,
                    child: FilterButton(
                        onFilter: _handleFilter, filterOptions: filterOptions)),
                //Page count
                Positioned(
                  top: MediaQuery.of(context).size.width / 2.5 -
                      40 +
                      top_padding,
                  left: MediaQuery.of(context).size.width / 2.5 +
                      90 +
                      150 +
                      left_padding,
                  child: Text(
                    "Page: ${filteredTransactions.isEmpty ? 0 : (_currentPage + 1)} / ${filteredTransactions.length % _pageLength == 0 ? filteredTransactions.length ~/ _pageLength : (filteredTransactions.length ~/ _pageLength) + 1}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
