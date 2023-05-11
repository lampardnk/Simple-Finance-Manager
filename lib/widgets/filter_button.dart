import 'package:flutter/material.dart';

enum FilterOptions {
  Last7Days,
  Last30Days,
  Under30,
  Above30,
  Food,
  Entertainment,
  Healthcare,
  Utilities,
  Shopping,
  Others,
  None, // Add this to handle the case when no filter is selected
}

class FilterButton extends StatefulWidget {
  final Function(FilterOptions) onFilter;

  FilterButton({required this.onFilter});

  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  FilterOptions _selectedFilter = FilterOptions.None;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterOptions>(
      icon: Icon(Icons.filter_list),
      onSelected: (FilterOptions result) {
        setState(() {
          _selectedFilter = result;
        });
        widget.onFilter(_selectedFilter);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOptions>>[
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.None,
          child: Text('All'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Last7Days,
          child: Text('From last 7 days'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Last30Days,
          child: Text('From last 30 days'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Under30,
          child: Text('Under \$30'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Above30,
          child: Text('Above \$30'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Food,
          child: Text('Food'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Entertainment,
          child: Text('Entertainment'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Healthcare,
          child: Text('Healthcare'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Utilities,
          child: Text('Utilities'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Shopping,
          child: Text('Shopping'),
        ),
        const PopupMenuItem<FilterOptions>(
          value: FilterOptions.Others,
          child: Text('Others'),
        ),
      ],
    );
  }
}
