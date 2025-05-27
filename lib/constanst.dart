import 'package:flutter_super_app/mini_app.dart';

class AppConstant {
  static List<MiniApp> apps = [
    MiniApp(
      id: "1",
      name: "app1",
      link:
          "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app1.zip",
      isEnable: true,
    ),
    MiniApp(
      id: "2",
      name: "app2",
      link:
          "https://raw.githubusercontent.com/toilathor/store_mini_app/refs/heads/master/app2.zip",
      isEnable: false,
    ),
  ];

  static const folderApps = "mini_apps";
}
