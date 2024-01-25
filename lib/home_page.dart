import 'package:first_app/widgets/budget_notification.dart';
import 'package:flutter/material.dart';
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_io.dart' as idb_io;
import '/models/transaction.dart';
import 'models/budget.dart';
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
  final String _budgetsKey = "budget";
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadBudgets();
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
    print("Transactions loaded successfully");
    setState(() {});

    db.close();
  }

  Future<void> _loadBudgets() async {
    print("Loading budgets...");
    idb.IdbFactory idbFactory = idb_io.getIdbFactorySembastIo('./idb/');
    idb.Database db = await idbFactory.open('budget_settings', version: 1,
        onUpgradeNeeded: (idb.VersionChangeEvent event) {
      idb.Database db = event.database;
      db.createObjectStore(_budgetsKey);
    });
    idb.ObjectStore store = db
        .transaction(_budgetsKey, idb.idbModeReadOnly)
        .objectStore(_budgetsKey);
    List<dynamic> budgetsList = await store.getAll();

    _budgets =
        budgetsList.map((budgetJson) => Budget.fromJson(budgetJson)).toList();

    print("Budgets loaded successfully");
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
    print("Transactions saved successfully");

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
    Navigator.of(context)
        .push(
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
    )
        .then((_) {
      // This block is executed when returning back to HomePage
      _showBackMessage('Returned from adding a transaction');
    });
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

  void _saveBudget() async {
    print("Saving budgets...");
    idb.IdbFactory idbFactory = idb_io.getIdbFactorySembastIo('./idb/');
    idb.Database? db;

    try {
      db = await idbFactory.open('budget_settings', version: 1,
          onUpgradeNeeded: (idb.VersionChangeEvent event) {
        idb.Database db = event.database;
        db.createObjectStore(_budgetsKey);
      });

      idb.Transaction transaction =
          db.transaction(_budgetsKey, idb.idbModeReadWrite);
      idb.ObjectStore store = transaction.objectStore(_budgetsKey);

      // Update or add each budget
      for (Budget budget in _budgets) {
        await store.delete(budget.type);
        await store.put(budget.toJson(), budget.type);
      }

      await transaction.completed;
      print("Budgets saved successfully");

      setState(() {});
    } catch (e) {
      print("Error in saving budgets: $e");
    } finally {
      db?.close();
    }
  }

  void addBudget(String type, double amount) async {
    final newBg = Budget(
      type: type,
      amount: amount,
    );

    setState(() {
      _budgets.add(newBg);
      _saveBudget();
      print("Budget added successfully: $newBg");
    });
  }

  void deleteBudget(String type) async {
    final deletedBudget = _budgets.firstWhere((budget) => budget.type == type);
    setState(() {
      _budgets.remove(deletedBudget);
      _saveBudget();
      print("Budget deleted successfully: $type");
    });
  }

  void editBudget(String type, double amount) async {
    final newBg = Budget(
      type: type,
      amount: amount,
    );
    setState(() {
      _budgets.removeWhere((budget) => budget.type == type);
      _budgets.add(newBg);
      _saveBudget();
      print("Budget edited successfully: $newBg");
    });
  }

  void _showBackMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: BudgetNotification(
                  budgets: _budgets, transactions: _transactions),
            ),
          ],
        ),
        backgroundColor: Colors.grey[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 6.0,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Finance Manager'),
        actions: [
          BudgetNotification(budgets: _budgets, transactions: _transactions),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openAddTransaction(context),
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => BudgetSettingsPage(
                          budgets: _budgets,
                          addBudget: addBudget,
                          editBudget: editBudget,
                        )),
              );
            },
          ),
        ],
      ),
      body: SummaryPage(_transactions, _budgets),
    );
  }
}
