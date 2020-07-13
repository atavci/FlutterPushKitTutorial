import 'package:flutter/material.dart';
import 'file:///C:/Users/a84167745/Documents/Work/Blog/PushKit/flutter_push_kit_tutorial/lib/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HMS Push Kit Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}