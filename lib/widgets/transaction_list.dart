import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'delete_button.dart';
import 'edit_button.dart';
import '../models/transaction.dart'; // import your transaction model

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final int _currentPage;
  final int _pageLength;
  final Function editTransaction;
  final Function deleteTransaction; // new property

  TransactionList(this.transactions, this._currentPage, this._pageLength,
      this.editTransaction, this.deleteTransaction); // updated

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom -
          350, //Higher value shorter list
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
                int actualIndex =
                    widget._currentPage * widget._pageLength + index;
                if (actualIndex < widget.transactions.length) {
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
                            child: Text(widget.transactions[actualIndex].title,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                widget.transactions[actualIndex].category,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                DateFormat.yMMMd().format(
                                    widget.transactions[actualIndex].date),
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                '\$${widget.transactions[actualIndex].amount.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: Row(
                            children: [
                              EditButton(
                                editTransaction: () => widget.editTransaction(
                                    widget.transactions[actualIndex]),
                              ),
                              SizedBox(width: 10),
                              DeleteButton(
                                  deleteTransaction: () =>
                                      widget.deleteTransaction(
                                          widget.transactions[actualIndex])),
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
