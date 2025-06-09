import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/logger.dart';
import 'package:flutter_super_app/models/user_repository.dart';
import 'package:flutter_super_app/services/api_domain.dart';
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
                        'https://localhost:$_port/${widget.argument?.appName}/index.html',
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
                    shouldInterceptRequest: _shouldInterceptRequest,
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
                          targetOrigin: WebUri("https://localhost:8080"),
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
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      // Đây là nơi bạn kiểm tra chứng chỉ
                      // challenge.protectionSpace.host sẽ là 'localhost' hoặc '127.0.0.1'
                      // challenge.protectionSpace.port sẽ là 8080

                      // Trong một ứng dụng thực tế, bạn sẽ kiểm tra
                      // Certificate chain của challenge.
                      // Ví dụ, bạn sẽ load chứng chỉ gốc của bạn (server.crt)
                      // và kiểm tra xem chứng chỉ server.crt có nằm trong chuỗi được trình bày bởi server không.

                      // Để đơn giản hóa cho localhost và chứng chỉ tự ký,
                      // bạn có thể chấp nhận nếu host và port khớp.
                      // TUY NHIÊN, CÁCH NÀY KHÔNG THỰC SỰ KIỂM TRA CHỨNG CHỈ!
                      // Nó chỉ chấp nhận nếu host/port đúng.
                      // ĐỂ KIỂM TRA CHỨNG CHỈ: bạn cần so sánh fingerprint (SHA-256) của chứng chỉ
                      // nhận được với fingerprint của chứng chỉ bạn đã tạo.

                      // Lấy fingerprint của chứng chỉ đã tạo (server.crt)
                      // Bạn có thể tính toán fingerprint này trước và lưu nó vào một biến const
                      // Ví dụ: final String expectedCertSha256Fingerprint = 'A1B2C3D4...'; // Cần tính toán
                      // Bạn có thể dùng openssl để tính toán:
                      // openssl x509 -in server.crt -noout -fingerprint -sha256

                      // Để đơn giản hóa DEBUG, có thể chấp nhận tất cả cho localhost (KHÔNG NÊN TRONG PROD)
                      if (challenge.protectionSpace.host == 'localhost' ||
                          challenge.protectionSpace.host == '127.0.0.1') {
                        // Trong production, bạn phải kiểm tra SHA-256 fingerprint của chứng chỉ nhận được
                        // và so sánh với fingerprint của chứng chỉ server.crt bạn đã tạo.
                        // Nếu khớp, bạn trả về Allow.

                        // Ví dụ:
                        // final receivedCert = challenge.iosCredential?.certificates?.first; // iOS
                        // final receivedCert = challenge.androidCertificate; // Android

                        // Kiểm tra và chấp nhận (cần logic mạnh hơn ở đây)
                        return ServerTrustAuthResponse(
                            action: ServerTrustAuthResponseAction.PROCEED);
                      }

                      return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.CANCEL);
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

  Future<WebResourceResponse?> _shouldInterceptRequest(
      InAppWebViewController controller, WebResourceRequest request) async {
    final uri = request.url;
    final domain = '${uri.scheme}://${uri.host}';

    if (uri.rawValue.startsWith('https://localhost:8080')) {
      return null; // KHÔNG intercept → load bình thường
    }

    final token = ApiDomainService.I.createMiniAppAccessToken(
      miniAppId: AppConstant.jwtSecretKey,
      allowedDomains: AppConstant.apiDomains['3'],
    );

    final verified = ApiDomainService.I.verifyDomainFromToken(token, domain);

    if (!verified) {
      AppLogger.e(domain);
      return WebResourceResponse(
        contentType: 'text/plain',
        data: Uint8List.fromList('Blocked by domain policy'.codeUnits),
        statusCode: 403,
      );
    }

    return null; // allow
  }
}
