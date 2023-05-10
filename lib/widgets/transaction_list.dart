import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_app/models/transaction.dart'; // import your transaction model

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final int _currentPage;
  final Function editTransaction;
  final Function deleteTransaction; // new property

  TransactionList(this.transactions, this._currentPage, this.editTransaction,
      this.deleteTransaction); // updated

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          320,
      width: MediaQuery.of(context).size.width / 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: Text('Title',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Edit/Delete',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                int actualIndex = _currentPage * 5 + index;
                if (actualIndex < transactions.length) {
                  // Display transaction
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4.0),
                      color: actualIndex % 2 == 0
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(transactions[actualIndex].title,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(transactions[actualIndex].category,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                DateFormat.yMMMd()
                                    .format(transactions[actualIndex].date),
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                '\$${transactions[actualIndex].amount.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => editTransaction(
                                    transactions[actualIndex]), // edit button
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteTransaction(
                                    transactions[actualIndex]
                                        .id), // delete button
                              ),
                            ],
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
          ),
        ],
      ),
    );
  }
}
