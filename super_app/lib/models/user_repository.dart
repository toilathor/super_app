import 'package:flutter/material.dart';
import 'package:flutter_super_app/core/router.dart';
import 'package:flutter_super_app/services/secure_storage_service.dart';

class UserRepository {
  UserRepository._();

  static UserRepository? _instance;

  static UserRepository get I => _instance ??= UserRepository._();

  // ..... TODO: VALUES ........................................................
  String? token;

  // ..... TODO: GETTERS/SETTERS .................................................

  // ..... TODO: METHODS .........................................................
  Future<void> logout() async {
    Navigator.pushNamedAndRemoveUntil(
      AppRoutes.navigatorKey.currentContext!,
      AppRoutes.login,
      (route) => false,
    );

    await SecureStorageService.I.deleteToken();
  }
}
