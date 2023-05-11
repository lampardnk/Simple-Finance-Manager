import 'package:flutter/material.dart';
import 'package:first_app/home_page.dart';
import 'package:flutter/rendering.dart';

void main() async {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
