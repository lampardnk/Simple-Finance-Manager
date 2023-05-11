import 'package:flutter/material.dart';

class DeleteButton extends StatefulWidget {
  final Function deleteTransaction;

  DeleteButton({required this.deleteTransaction});

  @override
  _DeleteButtonState createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool _isHoveringDelete = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _isHoveringDelete = true),
      onExit: (event) => setState(() => _isHoveringDelete = false),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: _isHoveringDelete ? Colors.red : Colors.transparent,
        child: InkWell(
          onTap: () => widget.deleteTransaction(),
          child: Icon(Icons.delete,
              color: _isHoveringDelete ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
