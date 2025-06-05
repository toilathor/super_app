import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/core/logger.dart';

import 'core/router.dart';
import 'services/root_check_service.dart';

WebViewEnvironment? webViewEnvironment;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra root/jailbreak device
  final isRooted = await _checkDeviceSecurity();

  AppLogger.d(isRooted);

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

    webViewEnvironment = await WebViewEnvironment.create(
        settings:
            WebViewEnvironmentSettings(userDataFolder: 'YOUR_CUSTOM_PATH'));
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(
    MaterialApp(
      navigatorKey: AppRoutes.navigatorKey,
      title: "Súp pờ Áp",
      routes: AppRoutes.routes,
      initialRoute: isRooted ? AppRoutes.rootedDevicePage : AppRoutes.root,
    ),
  );
}

/// Kiểm tra bảo mật device trước khi khởi chạy app
Future<bool> _checkDeviceSecurity() async {
  try {
    final rootCheckService = RootCheckService.I;

    // Lấy thông tin chi tiết về trạng thái bảo mật
    final securityStatus = await rootCheckService.getSecurityStatus();

    // Log thông tin bảo mật (chỉ trong debug mode)
    if (kDebugMode) {
      print('=== DEVICE SECURITY STATUS ===');
      print('Root/Jailbreak: ${securityStatus['isRooted']}');
      print('Android Root: ${securityStatus['isAndroidRooted']}');
      print('iOS Jailbreak: ${securityStatus['isIOSJailbroken']}');
      print('Developer Mode: ${securityStatus['isDeveloperMode']}');
      print('Device Safe: ${await rootCheckService.isDeviceSafe()}');
      print('==============================');
    }

    // Kiểm tra nếu device bị root/jailbreak
    final isRooted = await rootCheckService.isDeviceRooted();
    if (isRooted && !kDebugMode) {
      throw Exception('Device is rooted/jailbroken!');
    }
    return isRooted;
  } catch (e) {
    return true;
  }
}
