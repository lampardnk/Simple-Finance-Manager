import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:first_app/models/transaction.dart';
import 'package:first_app/summary_page.dart';
import 'package:first_app/add_transaction_page.dart';
import 'package:first_app/transaction_history.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box<Transaction>? _transactionsBox;

  @override
  void initState() {
    super.initState();
    _openTransactionsBox();
  }

  Future<void> _openTransactionsBox() async {
    _transactionsBox = await Hive.openBox<Transaction>('transactions');
  }

  void _addNewTransaction(String title, double amount, String category) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );

    setState(() {
      _transactionsBox!.add(newTx);
    });
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddTransactionPage(_addNewTransaction)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _openTransactionsBox(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ValueListenableBuilder(
            valueListenable: _transactionsBox!.listenable(),
            builder: (context, Box<Transaction> box, _) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Personal Finance Manager'),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _openAddTransaction(context),
                    ),
                  ],
                ),
                body: SummaryPage(box.values.toList()),
              );
            },
          );
        } else {
          // Show a loading indicator while waiting for the box to open
          return Scaffold(
            appBar: AppBar(title: Text('Personal Finance Manager')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
