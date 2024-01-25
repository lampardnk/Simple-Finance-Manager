import 'package:flutter/material.dart';

class FilterOption {
  final String name;
  bool isSelected;

  FilterOption({required this.name, this.isSelected = false});
}

class FilterButton extends StatefulWidget {
  final Function(List<FilterOption>) onFilter;
  final List<FilterOption> filterOptions;

  FilterButton({required this.onFilter, required this.filterOptions});

  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  List<FilterOption> selectedOptions = [];

  void _showFilterDialog(BuildContext context) {
    selectedOptions = widget.filterOptions
        .map((option) =>
            FilterOption(name: option.name, isSelected: option.isSelected))
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Select Filters'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: selectedOptions.map((option) {
                  return CheckboxListTile(
                    title: Text(option.name),
                    value: option.isSelected,
                    onChanged: (value) {
                      setState(() {
                        option.isSelected = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  for (var option in widget.filterOptions) {
                    option.isSelected =
                      selectedOptions
                          .firstWhere((o) => o.name == option.name)
                          .isSelected;
                  }
                  widget.onFilter(widget.filterOptions);
                },
                child: Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => _showFilterDialog(context),
    );
  }
}
