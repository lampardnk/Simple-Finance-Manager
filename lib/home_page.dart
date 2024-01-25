import 'package:flutter/material.dart';
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_io.dart' as idb_io;
import '/models/transaction.dart';
import 'pages/summary_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/edit_transaction_page.dart';
import 'pages/budget_settings_page.dart'; // Adjust the import path as needed

import 'keys.dart';

class HomePage extends StatefulWidget {
  HomePage() : super(key: homePageKey);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String _transactionsKey = "transactions";
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    print("Loading transactions...");
    idb.IdbFactory idbFactory = idb_io.getIdbFactorySembastIo('./idb/');
    idb.Database db = await idbFactory.open('transaction_db', version: 1,
        onUpgradeNeeded: (idb.VersionChangeEvent event) {
      idb.Database db = event.database;
      db.createObjectStore(_transactionsKey);
    });
    idb.ObjectStore store = db
        .transaction(_transactionsKey, idb.idbModeReadOnly)
        .objectStore(_transactionsKey);
    List<dynamic> transactionsList = await store.getAll();

    _transactions = transactionsList
        .map((transactionJson) => Transaction.fromJson(transactionJson))
        .toList();
    print("Transactions loaded successfully: $_transactions");
    setState(() {});

    db.close();
  }

  void _saveTransactions() async {
    print("Saving transactions...");
    idb.IdbFactory idbFactory = idb_io.getIdbFactorySembastIo('./idb/');
    print("Got idbFactory: $idbFactory");

    idb.Database? db;

    try {
      db = await idbFactory.open('transaction_db', version: 1,
          onUpgradeNeeded: (idb.VersionChangeEvent event) {
        idb.Database db = event.database;
        db.createObjectStore(_transactionsKey);
      });
      print("Opened database: $db");
    } catch (e) {
      print("Error opening database: $e");
    }

    if (db == null) {
      print("Database is null, cannot save transactions");
      return;
    }

    // Start a new transaction for write operations.
    idb.Transaction transaction =
        db.transaction(_transactionsKey, idb.idbModeReadWrite);
    print("Started transaction: $transaction");
    idb.ObjectStore store = transaction.objectStore(_transactionsKey);
    print("Got object store: $store");

    // Clear the store first.
    await store.clear();
    print("Cleared store");

    // Then save all the transactions in a single batch.
    for (Transaction transaction in _transactions) {
      await store.delete(transaction.id);
      await store.put(transaction.toJson(), transaction.id);
    }
    print("Saved transactions");

    // Wait for the transaction to complete.
    await transaction.completed;
    print("Transactions saved successfully: $_transactions");

    setState(() {});
    db.close();
  }

  void _addNewTransaction(
      String id, String title, double amount, String category, DateTime dt) {
    final newTx = Transaction(
      id: id,
      title: title,
      amount: amount,
      date: dt,
      category: category,
    );

    setState(() {
      _transactions.add(newTx);
      _saveTransactions();
      print("Transaction added successfully: $newTx");
    });
  }

  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionPage(_addNewTransaction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 450),
      ),
    );
  }

  void editTransaction(Transaction fT) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(
          transaction: fT,
          editTransaction: (id, newTitle, newAmount, newCategory, newDate) {
            final newTx = Transaction(
              id: id,
              title: newTitle,
              amount: newAmount,
              date: newDate,
              category: newCategory,
            );
            setState(() {
              _transactions.removeWhere((transaction) => transaction.id == id);
              _transactions.add(newTx);
              _saveTransactions();
              print("Transaction edited successfully: $newTx");
            });
          },
        ),
      ),
    );
  }

  void deleteTransaction(Transaction fT) {
    String id = fT.id;
    final deletedTransaction =
        _transactions.firstWhere((transaction) => transaction.id == id);
    setState(() {
      _transactions.remove(deletedTransaction);
      _saveTransactions();
      print("Transaction deleted successfully: $id");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedTransaction.title} has been deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo the deletion
            setState(() {
              _transactions.add(deletedTransaction);
              _saveTransactions();
              print("Transaction restored successfully: $id");
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Finance Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openAddTransaction(context),
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BudgetSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SummaryPage(_transactions),
    );
  }
}
