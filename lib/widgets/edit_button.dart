import 'package:flutter/material.dart';

class EditButton extends StatefulWidget {
  final Function editTransaction;

  EditButton({required this.editTransaction});

  @override
  _EditButtonState createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  bool _isHoveringEdit = false;
  Function get editTransaction => widget.editTransaction;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _isHoveringEdit = true),
      onExit: (event) => setState(() => _isHoveringEdit = false),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: _isHoveringEdit ? Colors.blue : Colors.transparent,
        child: InkWell(
          onTap: () => editTransaction(),
          child: Icon(Icons.edit,
              color: _isHoveringEdit ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
