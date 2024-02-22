import 'package:first_app/widgets/budget_notification.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sql;
import 'dart:async';
import 'package:path/path.dart' as p;
import '/models/transaction.dart';
import 'models/budget.dart';
import 'pages/summary_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/edit_transaction_page.dart';
import 'pages/budget_settings_page.dart';
import 'keys.dart';

class HomePage extends StatefulWidget {
  HomePage() : super(key: homePageKey);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String _transactionsTable = "transactions";
  final String _budgetsTable = "budgets";
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  late sql.Database database;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    var databasesPath = await sql.getDatabasesPath();
    String dbPath = p.join(databasesPath, 'finance_manager.db');
    print("Database: $dbPath");
    database = await sql.databaseFactoryFfi.openDatabase(dbPath);
    await database.execute(
        'CREATE TABLE IF NOT EXISTS $_transactionsTable (id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category TEXT)');
    await database.execute(
        'CREATE TABLE IF NOT EXISTS $_budgetsTable (type TEXT PRIMARY KEY, amount REAL)');
    _loadTransactions();
    _loadBudgets();
  }

  Future<void> _loadTransactions() async {
    List<Map<String, dynamic>> result =
        await database.query(_transactionsTable);
    _transactions = result
        .map((map) => Transaction(
              id: map['id'],
              title: map['title'],
              amount: map['amount'],
              date: DateTime.parse(map['date']),
              category: map['category'],
            ))
        .toList();
    setState(() {});
  }

  Future<void> _loadBudgets() async {
    List<Map<String, dynamic>> result = await database.query(_budgetsTable);
    _budgets = result
        .map((map) => Budget(
              type: map['type'],
              amount: map['amount'],
            ))
        .toList();
    setState(() {});
  }

  Future<void> _addNewTransaction(String id, String title, double amount,
      String category, DateTime dt) async {
    final newTx = Transaction(
      id: id,
      title: title,
      amount: amount,
      date: dt,
      category: category,
    );
    String sql =
        'INSERT INTO $_transactionsTable (id, title, amount, date, category) VALUES (?, ?, ?, ?, ?)';
    List<dynamic> arguments = [
      id,
      title,
      amount,
      dt.toIso8601String(),
      category
    ];
    await database.rawInsert(sql, arguments);
    setState(() {
      _transactions.add(newTx);
      print("Transaction added successfully: $newTx");
    });
  }

  void editTransaction(Transaction fT) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditTransactionPage(
          transaction: fT,
          editTransaction:
              (id, newTitle, newAmount, newCategory, newDate) async {
            final newTx = Transaction(
              id: id,
              title: newTitle,
              amount: newAmount,
              date: newDate,
              category: newCategory,
            );
            String sql =
                'UPDATE $_transactionsTable SET title = ?, amount = ?, date = ?, category = ? WHERE id = ?';
            List<dynamic> arguments = [
              newTitle,
              newAmount,
              newDate.toIso8601String(),
              newCategory,
              id
            ];
            await database.rawUpdate(sql, arguments);
            setState(() {
              _transactions.removeWhere((transaction) => transaction.id == id);
              _transactions.add(newTx);
              print("Transaction edited successfully: $newTx");
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: Duration(milliseconds: 450),
      ),
    ).then((_) {
      _showBackMessage();
    });
  }

  Future<void> deleteTransaction(Transaction fT) async {
    String id = fT.id;
    String sql = 'DELETE FROM $_transactionsTable WHERE id = ?';
    List<dynamic> arguments = [id];
    await database.rawDelete(sql, arguments);
    setState(() {
      _transactions.remove(fT);
      print("Transaction deleted successfully: $id");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fT.title} has been deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            String sql =
                'INSERT INTO $_transactionsTable (id, title, amount, date, category) VALUES (?, ?, ?, ?, ?)';
            List<dynamic> arguments = [
              fT.id,
              fT.title,
              fT.amount,
              fT.date.toIso8601String(),
              fT.category
            ];
            await database.rawInsert(sql, arguments);
            setState(() {
              _transactions.add(fT);
              print("Transaction restored successfully: $id");
            });
          },
        ),
      ),
    );
  }

  void addBudget(String type, double amount) async {
    final newBg = Budget(
      type: type,
      amount: amount,
    );

    String sql = 'INSERT INTO $_budgetsTable (type, amount) VALUES (?, ?)';
    List<dynamic> arguments = [type, amount];

    await database.rawInsert(sql, arguments);

    setState(() {
      _budgets.add(newBg);
      print("Budget added successfully: $newBg");
    });
  }

  void editBudget(String type, double amount) async {
    final newBg = Budget(
      type: type,
      amount: amount,
    );

    String sql = 'UPDATE $_budgetsTable SET amount = ? WHERE type = ?';
    List<dynamic> arguments = [amount, type];
    await database.rawUpdate(sql, arguments);
    setState(() {
      _budgets.removeWhere((budget) => budget.type == type);
      _budgets.add(newBg);
      print("Budget edited successfully: $newBg");
    });
  }

  void _showBackMessage() {
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
      _showBackMessage();
    });
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
