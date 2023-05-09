import 'package:flutter/material.dart';
import 'package:first_app/models/transaction.dart';

class TransactionHistory extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionHistory(this.transactions);

  List<Transaction> _sortedTransactions() {
    List<Transaction> sortedTransactions = List.from(transactions);
    sortedTransactions.sort((a, b) {
      int cmp = a.category.compareTo(b.category);
      if (cmp != 0) return cmp;
      return a.date.compareTo(b.date);
    });
    return sortedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = _sortedTransactions();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final tx = sortedTransactions[index];
        return ListTile(
          title: Text(tx.title),
          subtitle: Text(tx.category),
          trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
