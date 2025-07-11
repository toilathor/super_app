// TODO: App này test truyền dữ liệu

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

class SampleApp2 extends StatefulWidget {
  const SampleApp2({super.key});

  @override
  State<SampleApp2> createState() => _SampleApp2State();
}

class _SampleApp2State extends State<SampleApp2> {
  String? _receivedToken;
  html.MessagePort? port;

  @override
  void initState() {
    super.initState();

    // Thiết lập listener riêng để cập nhật UI khi nhận token
    html.window.onMessage.listen((event) {
      if (event.data == "capturePort") {
        // Nhận port từ event
        final receivedPort = event.ports.first;
        port = receivedPort;

        // Lắng nghe tin nhắn từ Flutter Mobile (qua WebView)
        port?.onMessage.listen((messageEvent) {
          print('Nhận từ Flutter Mobile: ${messageEvent.data}');
        });

        // (Tuỳ chọn) Gửi phản hồi về lại Flutter Mobile
        port?.postMessage("Mini App đã nhận port!");

        try {
          final data = jsonDecode(event.data);
          if (data['type'] == 'AUTH_TOKEN') {
            setState(() {
              _receivedToken = data['token'];
            });
          }
        } catch (_) {}
      } else if (event.data is Map) {
        if (event.data['type'] == 'AUTH_TOKEN') {
          setState(() {
            _receivedToken = event.data['token'];
          });
        }
      }
    });
  }

  void _requestTokenFromSuperApp() {
    // (Tuỳ chọn) Gửi phản hồi về lại Flutter Mobile
    port?.postMessage("Mini App đã nhận port!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Flutter Web App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _receivedToken == null
                  ? 'No token received yet'
                  : 'Received token:\n$_receivedToken',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestTokenFromSuperApp,
              child: const Text('Request Token from Super App'),
            )
          ],
        ),
      ),
    );
  }
}
