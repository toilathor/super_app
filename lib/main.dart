import 'package:flutter/material.dart';
import 'package:flutter_super_app/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  runApp(MaterialApp(home: HomeScreen()));
}
