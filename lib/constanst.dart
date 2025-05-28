import 'package:flutter_super_app/mini_app.dart';

class AppConstant {
  static List<MiniApp> apps = [
    MiniApp(
      id: "1",
      name: "app1",
      link:
          "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app1.zip",
      isEnable: true,
      currentVersion: 2,
      version: 0,
    ),
    MiniApp(
      id: "2",
      name: "app2",
      link:
          "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app2.zip",
      isEnable: false,
      currentVersion: 1,
      version: 1,
    ),
  ];

  static const folderApps = "mini_apps";
}
