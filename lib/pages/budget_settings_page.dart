import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/budget.dart'; // Ensure this is the correct path to Budget model

class BudgetSettingsPage extends StatefulWidget {
  final List<Budget> budgets; // Pass budgets from HomePage
  final Function addBudget;
  final Function editBudget;

  BudgetSettingsPage({
    Key? key,
    required this.budgets,
    required this.addBudget,
    required this.editBudget,
  }) : super(key: key);

  @override
  _BudgetSettingsPageState createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  Map<String, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers with current budget values
    _categoryControllers = {
      'Monthly': TextEditingController(),
      'Weekly': TextEditingController(),
      'Food': TextEditingController(),
      'Entertainment': TextEditingController(),
      'Healthcare': TextEditingController(),
      'Utilities': TextEditingController(),
      'Shopping': TextEditingController(),
      'Others': TextEditingController(),
    };

    for (var budget in widget.budgets) {
      if (_categoryControllers.containsKey(budget.type)) {
        _categoryControllers[budget.type]!.text = budget.amount.toString();
      }
    }
  }

  void _updateBudget(String category, String value) async {
    double? amount = double.tryParse(value);
    if (amount == null || amount < 0) {
      // Show error if not a valid positive number
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid positive number')),
      );
      return;
    }

    Budget? existingBudget = widget.budgets.firstWhereOrNull(
      (b) => b.type == category,
    );

    if (existingBudget != null) {
      // Edit existing budget
      widget.editBudget(category, amount);
    } else {
      // Add new budget
      widget.addBudget(category, amount);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$category budget updated')),
    );
  }

  Widget _budgetInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: label),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _updateBudget(label, controller.text),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  // Set the budget to 0 when 'X' button is pressed
                  _updateBudget(label, '0');
                  controller.text =
                      '0'; // Update the text field to reflect the change
                  setState(() {});
                },
              ),
            ],
          ),
          Text(
              'Current Budget: ${controller.text.isEmpty ? 'Not Set' : controller.text}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ..._categoryControllers.entries
                .map((entry) => _budgetInputField(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
