import 'package:flutter/material.dart';
import 'package:mini_app/app/sample_app_3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(home: SampleApp1());
    // return MaterialApp(home: SampleApp2());
    return MaterialApp(home: SampleApp3());
  }
}
