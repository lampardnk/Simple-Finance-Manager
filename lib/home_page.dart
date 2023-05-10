import 'package:flutter/material.dart';
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_io.dart' as idb_io;
import 'package:first_app/models/transaction.dart';
import 'package:first_app/summary_page.dart';
import 'package:first_app/add_transaction_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      await store.put(transaction.toJson(), transaction.id);
    }
    print("Saved transactions");

    // Wait for the transaction to complete.
    await transaction.completed;
    print("Transactions saved successfully: $_transactions");

    db.close();
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
      _transactions.add(newTx);
      _saveTransactions();
      print("Transaction added successfully: $newTx");
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
      body: SummaryPage(_transactions),
    );
  }
}
