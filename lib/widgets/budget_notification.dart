import 'package:first_app/models/budget.dart';
import 'package:first_app/models/transaction.dart';
import 'package:flutter/material.dart';

class BudgetNotification extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;

  BudgetNotification({required this.budgets, required this.transactions});

  String _getExceededBudgetsText() {
    DateTime now = DateTime.now();
    List<String> exceededBudgets = [];

    for (var budget in budgets) {
      double transactionSum;

      if (budget.type == 'Monthly') {
        transactionSum = transactions
            .where((t) => t.date.isAfter(now.subtract(Duration(days: 30))))
            .fold(0.0, (sum, item) => sum + item.amount);
      } else if (budget.type == 'Weekly') {
        transactionSum = transactions
            .where((t) => t.date.isAfter(now.subtract(Duration(days: 7))))
            .fold(0.0, (sum, item) => sum + item.amount);
      } else {
        transactionSum = transactions
            .where((t) => t.category == budget.type)
            .fold(0.0, (sum, item) => sum + item.amount);
      }

      if (transactionSum >= budget.amount) {
        exceededBudgets.add(budget.type);
      }
    }

    return exceededBudgets.isEmpty
        ? 'All Budgets Within Limit'
        : 'Exceeded: ${exceededBudgets.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    String exceededBudgetsText = _getExceededBudgetsText();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Text(
          exceededBudgetsText,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
