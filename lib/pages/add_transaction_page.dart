import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final Function addTransaction;

  AddTransactionPage(this.addTransaction);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);
    final enteredCategory = _selectedCategory;

    if (enteredTitle.isEmpty || enteredAmount <= 0 || enteredCategory.isEmpty) {
      return;
    }

    widget.addTransaction(
      DateTime.now().toString(),
      enteredTitle,
      enteredAmount,
      enteredCategory,
      _selectedDate,
    );

    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isHoveringUp = false;
  bool _isHoveringDown = false;

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
            DropdownButton<String>(
              value: _selectedCategory,
              items: <String>[
                'Food',
                'Entertainment',
                'Healthcare',
                'Utilities',
                'Shopping',
                'Others'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            Text("Selected date: ${DateFormat('yMMMd').format(_selectedDate)}"),
            SizedBox(height: 16),
            MouseRegion(
              onHover: (event) => setState(() => _isHoveringUp = true),
              onExit: (event) => setState(() => _isHoveringUp = false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: Transform.scale(
                  scale: _isHoveringUp ? 1.1 : 1.0,
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        _isHoveringUp
                            ? Colors.blueGrey[100]
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      'Select Date',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            MouseRegion(
              onHover: (event) => setState(() => _isHoveringDown = true),
              onExit: (event) => setState(() => _isHoveringDown = false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: Transform.scale(
                  scale: _isHoveringDown ? 1.1 : 1.0,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        _isHoveringDown
                            ? Colors.blueGrey[100]
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      'Add Transaction',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
