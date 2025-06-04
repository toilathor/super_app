import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/core/constanst.dart';
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

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
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
                        await port1
                            .postMessage(WebMessage(data: "$message and back"));
                      });

                      // transfer port2 to the webpage to initialize the communication
                      await controller.postWebMessage(
                        message:
                            WebMessage(data: "capturePort", ports: [port2!]),
                        targetOrigin: WebUri("http://localhost:8080"),
                      );
                    }
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    webViewController = controller;
    await webViewController?.clearHistory();
  }
}
