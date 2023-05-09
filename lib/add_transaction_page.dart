import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  final Function addTransaction;

  AddTransactionPage(this.addTransaction);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);
    final enteredCategory = _categoryController.text;

    if (enteredTitle.isEmpty || enteredAmount <= 0 || enteredCategory.isEmpty) {
      return;
    }

    widget.addTransaction(
      enteredTitle,
      enteredAmount,
      enteredCategory,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Category'),
              controller: _categoryController,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Add Transaction'),
              onPressed: _submitData,
            ),
          ],
        ),
      ),
    );
  }
}
