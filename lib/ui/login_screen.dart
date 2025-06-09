import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/router.dart';
import 'package:flutter_super_app/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: "admin");
  final _passwordCtrl = TextEditingController(text: "123456");
  String? _error;

  Future<void> _login() async {
    final user = _usernameCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (user == 'admin' && pass == '123456') {
      final token = _generateMockJWT(userId: user);
      await SecureStorageService.I.saveToken(token);

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() => _error = "Invalid credentials");
    }
  }

  String _generateMockJWT({required String userId}) {
    final jwt = JWT(
      {
        'id': userId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp':
            DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch ~/
                1000,
      },
    );

    // Replace AppConstant.secretKey with your actual secret
    return jwt.sign(
      SecretKey(AppConstant.jwtSecretKey),
      algorithm: JWTAlgorithm.HS256,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SuperApp Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: InputDecoration(
                labelText: "Username",
              ),
            ),
            TextField(
              controller: _passwordCtrl,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
