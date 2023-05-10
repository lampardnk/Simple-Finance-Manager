import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_app/models/transaction.dart'; // import your transaction model

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final int _currentPage;

  TransactionList(this.transactions, this._currentPage);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          280,
      width: MediaQuery.of(context).size.width / 2,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          int actualIndex = _currentPage * 10 + index;
          if (actualIndex < transactions.length) {
            // Display transaction
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      transactions[actualIndex].title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      transactions[actualIndex].category,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMd().format(transactions[actualIndex].date),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${transactions[actualIndex].amount.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Display empty row
            return null;
          }
        },
      ),
    );
  }
}
