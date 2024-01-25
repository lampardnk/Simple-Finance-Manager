import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'summary_page.dart'; // Import SummaryPage for showCustomToast

class BudgetSettingsPage extends StatefulWidget {
  @override
  _BudgetSettingsPageState createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _weeklyController = TextEditingController();
  Map<String, TextEditingController> categoryControllers = {};

  @override
  void initState() {
    super.initState();
    categoryControllers = {
      'Food': TextEditingController(),
      'Entertainment': TextEditingController(),
      'Healthcare': TextEditingController(),
      'Utilities': TextEditingController(),
      'Shopping': TextEditingController(),
      'Other': TextEditingController(),
    };
    loadBudgetSettings();
  }

  Future<void> loadBudgetSettings() async {
    final budgetSettings = await readBudgetSettings();
    setState(() {
      _monthlyController.text = budgetSettings['Monthly'] ?? '';
      _weeklyController.text = budgetSettings['Weekly'] ?? '';
      categoryControllers.forEach((key, controller) {
        controller.text = budgetSettings[key] ?? '';
      });
    });
  }

  Future<Map<String, String>> readBudgetSettings() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        return {};
      }
      String contents = await file.readAsString();
      return Map<String, String>.from(json.decode(contents));
    } catch (e) {
      return {};
    }
  }

  Future<File> get _localFile async {
    return File('idb/budget_settings');
  }

  void updateBudget(String category, String value) async {
    if (value.isEmpty || double.tryParse(value) == null) {
      SummaryPage.showCustomToast(
          context, "Please enter a valid number for $category");
      return;
    }

    double budget = double.parse(value);
    String budgetType =
        budget == 0 ? 'Not Set' : budget.toStringAsFixed(2); // Changed here

    // Update the controller text
    setState(() {
      categoryControllers[category]?.text = budgetType;
    });

    // Save the updated settings
    final budgetSettings = await readBudgetSettings();
    budgetSettings[category] = budgetType;
    await writeBudgetSettings(budgetSettings);

    SummaryPage.showCustomToast(context, "$category Budget Set: $budgetType");
  }

  Future<File> writeBudgetSettings(Map<String, String> budgetSettings) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(budgetSettings));
  }

  Widget budgetInputField(String label, TextEditingController controller) {
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
                  onChanged: (value) {
                    if (double.tryParse(value) == null && value.isNotEmpty) {
                      controller.clear();
                      SummaryPage.showCustomToast(
                          context, "Please enter a valid number");
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => updateBudget(label, controller.text),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  controller.clear();
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
            budgetInputField('Monthly', _monthlyController),
            budgetInputField('Weekly', _weeklyController),
            ...categoryControllers.entries
                .map((entry) => budgetInputField(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _weeklyController.dispose();
    categoryControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
