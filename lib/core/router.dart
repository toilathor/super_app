import 'package:flutter/material.dart';
import 'package:flutter_super_app/ui/home_screen.dart';
import 'package:flutter_super_app/ui/inapp_webview_screen.dart';
import 'package:flutter_super_app/ui/login_screen.dart';

class AppRoutes {
  static const rootedDevicePage = '/rooted-device-page';
  static const root = '/';
  static const home = '/home';
  static const login = '/login';
  static const miniApp = '/mini_app';

  static Map<String, WidgetBuilder> routes = {
    rootedDevicePage: (context) => const Scaffold(
          body: Center(
            child: Text('Rooted DevicePage Page'),
          ),
        ),
    root: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    miniApp: (context) {
      // TODO: Viết safe as
      final argument = ModalRoute.of(context)?.settings.arguments
          as InAppWebViewScreenArgument?;

      return InAppWebViewScreen(argument: argument);
    },
  };
}
