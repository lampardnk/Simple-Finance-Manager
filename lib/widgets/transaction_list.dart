import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'delete_button.dart';
import 'edit_button.dart';
import 'filter_button.dart';
import '../models/transaction.dart'; // import your transaction model

class TransactionList extends StatefulWidget {
  final List<Transaction> filteredTransactions;
  final int _currentPage;
  final int _pageLength;
  final Function editTransaction;
  final Function deleteTransaction; // new property

  TransactionList(
      this.filteredTransactions,
      this._currentPage,
      this._pageLength,
      this.editTransaction,
      this.deleteTransaction); // updated

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<Transaction> get fT => widget.filteredTransactions;
  int get _currentPage => widget._currentPage;
  int get _pageLength => widget._pageLength;
  Function get editTransaction => widget.editTransaction;
  Function get deleteTransaction => widget.deleteTransaction;

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
                int actualIndex = _currentPage * _pageLength + index;
                if (actualIndex < fT.length) {
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
                            child: Text(fT[actualIndex].title,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(fT[actualIndex].category,
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                DateFormat.yMMMd().format(fT[actualIndex].date),
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text(
                                '\$${fT[actualIndex].amount.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: Row(
                            children: [
                              EditButton(
                                editTransaction: () =>
                                    editTransaction(fT[actualIndex]),
                              ),
                              SizedBox(width: 10),
                              DeleteButton(
                                  deleteTransaction: () =>
                                      deleteTransaction(fT[actualIndex])),
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
