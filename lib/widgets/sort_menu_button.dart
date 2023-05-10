import 'package:flutter/material.dart';

class SortMenuButton extends StatelessWidget {
  final Function(String) onSelected;

  SortMenuButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'Name',
            child: Text('Sort by Name'),
          ),
          PopupMenuItem<String>(
            value: 'Category',
            child: Text('Sort by Category'),
          ),
          PopupMenuItem<String>(
            value: 'Date Ascending',
            child: Text('Sort by Date (Ascending)'),
          ),
          PopupMenuItem<String>(
            value: 'Date Descending',
            child: Text('Sort by Date (Descending)'),
          ),
          PopupMenuItem<String>(
            value: 'Amount Ascending',
            child: Text('Sort by Amount (Ascending)'),
          ),
          PopupMenuItem<String>(
            value: 'Amount Descending',
            child: Text('Sort by Amount (Descending)'),
          ),
        ];
      },
    );
  }
}
