import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/models/mini_app.dart';

class AppConstant {
  static const String jwtSecretKey = String.fromEnvironment(
    "JWT_SECRET",
    defaultValue: "FAIL_TOKEN",
  );

  static const String apiDomainSecretKey = String.fromEnvironment(
    "API_DOMAIN_SECRET_KEY",
  );

  static List<MiniApp> apps = [
    MiniApp(
      id: "1",
      name: "app1",
      link:
          "https://raw.githubusercontent.com/toilathor/app1/refs/heads/master/app1.zip",
      isEnable: true,
      currentVersion: 1,
      version: 1,
      checksum: "c8d92672226176e3477a9793f1581ab0",
      needDownload: true,
      gitHash: "73e94b49bd93a15341ead8483f7b47d9da6ec068",
    ),
    MiniApp(
      id: "2",
      name: "app2",
      link:
          "https://raw.githubusercontent.com/toilathor/app2/refs/heads/master/app2.zip",
      isEnable: true,
      currentVersion: 1,
      version: 1,
      checksum: "c74f913a4ae8e52fd31c7f0cea22de48",
      needDownload: true,
      gitHash: "68b837597ee21cd5d2ccb101e90d02608fe77f24",
    ),
    MiniApp(
      id: "3",
      name: "app3",
      link:
          "https://raw.githubusercontent.com/toilathor/app3/refs/heads/master/app3.zip",
      isEnable: true,
      currentVersion: 1,
      version: 1,
      checksum: "c5a1281f94e194ba24c6d8040ee22a92",
      needDownload: false,
      gitHash: "8b060baa78c819a54b2e062b2d23c25d47757b61",
    ),
  ];

  static const folderApps = "mini_apps";

  static InAppWebViewSettings settings = InAppWebViewSettings(
    // Bảo mật chung
    javaScriptEnabled: true,
    // Cần nếu Mini App là Flutter Web
    javaScriptCanOpenWindowsAutomatically: false,
    mediaPlaybackRequiresUserGesture: true,
    userAgent: "MySuperApp/1.0.0",
    incognito: true,
    clearCache: true,
    clearSessionCache: true,
    disableContextMenu: true,

    // Giới hạn quyền truy cập
    allowFileAccess: false,
    allowContentAccess: false,
    allowFileAccessFromFileURLs: false,
    allowUniversalAccessFromFileURLs: false,
    thirdPartyCookiesEnabled: false,
    safeBrowsingEnabled: true,

    // Iframe và media
    iframeAllow: "",
    // Chỉ bật nếu Mini App cần, ví dụ: "camera; microphone"
    iframeAllowFullscreen: false,
    // true nếu có tính năng fullscreen
    allowsInlineMediaPlayback: false,
    allowsAirPlayForMediaPlayback: false,

    // Điều khiển truy cập URL & debug
    useShouldInterceptRequest: true,
    useShouldOverrideUrlLoading: true,
    isFraudulentWebsiteWarningEnabled: true,
    isInspectable: kDebugMode,
    transparentBackground: false,

    // Zoom
    supportZoom: false,
    builtInZoomControls: false,
  );

  static const Map<String, dynamic> apiDomains = {
    '3': [
      "https://6695f99f0312447373c0957c.mockapi.io",
      "https://fonts.gstatic.com",
      "https://avatars.githubusercontent.com",
      "https://cdn.jsdelivr.net",
      "https://www.gstatic.com",
    ],
  };
}
