import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_super_app/models/mini_app.dart';

class AppConstant {
  static List<MiniApp> apps = [
    MiniApp(
        id: "1",
        name: "app1",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app1.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "bada73ee34d3c56226b98dfe2fc30ae9"),
    MiniApp(
        id: "2",
        name: "app2",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app2.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "c74f913a4ae8e52fd31c7f0cea22de48"),
    MiniApp(
        id: "3",
        name: "app3",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app3.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "5d0cf8b8ca22ad5ce63eee07a75d5610"),
    MiniApp(
        id: "4",
        name: "app4",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app4.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "0b994a2597d0451fe62b963606f1ceda"),
    MiniApp(
        id: "5",
        name: "app5",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app5.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "fc77cb2ecc13a1ff0a52ba0d3a3a673c"),
    MiniApp(
        id: "6",
        name: "app6",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app6.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "177aa982f3237714b8505c0a4e9f93a7"),
    MiniApp(
        id: "7",
        name: "app7",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app7.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "76b51e92ea6e6ec1807522321f1c31f1"),
    MiniApp(
        id: "8",
        name: "app8",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app8.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "866c95433e94d6d8179c95e0230edd6f"),
    MiniApp(
        id: "9",
        name: "app9",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app9.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "663289fd1338c51708ae4c71f0950451"),
    MiniApp(
        id: "10",
        name: "app10",
        link:
            "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app10.zip",
        isEnable: true,
        currentVersion: 1,
        version: 1,
        checksum: "f6a20e8348358228509bee4f6bdb525f"),
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
