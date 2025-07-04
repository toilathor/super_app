import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/logger.dart';
import 'package:flutter_super_app/models/user_repository.dart';
import 'package:flutter_super_app/services/secure_storage_service.dart';

class InAppWebViewScreenArgument {
  final String? appName;
  final String? folder;

  InAppWebViewScreenArgument({required this.appName, required this.folder});
}

class InAppWebViewScreen extends StatefulWidget {
  const InAppWebViewScreen({
    super.key,
    this.argument,
  });

  final InAppWebViewScreenArgument? argument;

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  final int _port = 8080;
  ValueNotifier<bool> showSplashScreen = ValueNotifier(true);

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
              future: SecureStorageService.I.getToken(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(
                        'http://localhost:$_port/${widget.argument?.appName}/index.html',
                      )),
                      headers: {"Authorization": 'Bearer ${snapshot.data}'},
                      httpShouldUsePipelining: true,
                    ),
                    onWebViewCreated: _onWebViewCreated,
                    onPermissionRequest: (controller, request) async {
                      return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT,
                      );
                    },
                    initialSettings: AppConstant.settings,
                    shouldInterceptRequest: (controller, request) async {
                      // Cho phép hoặc chặn request tại đây (tùy theo domain/token)
                      return null;
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url!;
                      if (uri.host != "localhost") {
                        return NavigationActionPolicy
                            .CANCEL; // Chặn mọi redirect ra ngoài
                      }
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      showSplashScreen.value = false;

                      await controller.evaluateJavascript(
                        source:
                            """window.superAppToken = "SECURE_TOKEN_FROM_NATIVE";""",
                      );
                      if (defaultTargetPlatform != TargetPlatform.android ||
                          await WebViewFeature.isFeatureSupported(
                              WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
                        // wait until the page is loaded, and then create the Web Message Channel
                        var webMessageChannel =
                            await controller.createWebMessageChannel();
                        var port1 = webMessageChannel?.port1;
                        var port2 = webMessageChannel?.port2;

                        // set the web message callback for the port1
                        await port1?.setWebMessageCallback((message) async {
                          // when it receives a message from the JavaScript side, respond back with another message.
                          await port1.postMessage(
                              WebMessage(data: "$message and back"));
                        });

                        // transfer port2 to the webpage to initialize the communication
                        await controller.postWebMessage(
                          message:
                              WebMessage(data: "capturePort", ports: [port2!]),
                          targetOrigin: WebUri("http://localhost:8080"),
                        );
                      }
                    },
                    onReceivedHttpError: (controller, request, error) {
                      if (error.statusCode == HttpStatus.unauthorized) {
                        _showSessionExpiredDialog();
                      }
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      AppLogger.d(consoleMessage);
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: showSplashScreen,
              builder: (context, showSplashScreenValue, child) {
                return AnimatedOpacity(
                  opacity: showSplashScreenValue ? 1 : 0,
                  duration: Duration(milliseconds: 250),
                  child: Hero(
                    tag: widget.argument?.appName ?? "",
                    child: Center(
                      child: FlutterLogo(
                        size: 120,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    webViewController = controller;
    await webViewController?.clearHistory();
    showSplashScreen.value = true;
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho tắt dialog khi chạm ngoài
      builder: (context) => AlertDialog(
        title: Text("Phiên đăng nhập đã kết thúc"),
        content: Text("Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng."),
        actions: [
          TextButton(
            onPressed: () {
              UserRepository.I.logout();
            },
            child: Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}
