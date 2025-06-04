import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/models/mini_app.dart';

class AppConstant {
  static const String secretKey = String.fromEnvironment(
    "JWT_SECRET",
    defaultValue: "FAIL_TOKEN",
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
      checksum: "ea8a52e1104462cfcc45ddb001709ba9",
      needDownload: false,
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
      needDownload: true,
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
}
