import 'package:flutter/material.dart';
import 'package:flutter_super_app/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(MaterialApp(home: HomeScreen()));
}
