import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/helper.dart';
import 'package:flutter_super_app/models/mini_app.dart';
import 'package:flutter_super_app/models/user_repository.dart';
import 'package:flutter_super_app/services/local_server.dart';
import 'package:flutter_super_app/ui/widgets/mini_app_tile.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MiniApp> apps = [];

  bool isLoading = false;
  late HttpServer server;
  late String userToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: UserRepository.I.logout,
          ),
        ],
      ),
      body: GridView.builder(
        shrinkWrap: true,
        itemCount: apps.length,
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 130,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (_, int index) {
          return MiniAppTile(
            miniApp: apps[index],
          );
        },
      ),
    );
  }

  Future<void> _initApps() async {
    setState(() {
      isLoading = true;
    });
    final dirDoc = await getApplicationDocumentsDirectory();
    final dirMiniApps = "${dirDoc.path}/${AppConstant.folderApps}";
    final List<String> routes = [];

    for (final app in AppConstant.apps) {
      final appDir = '$dirMiniApps/${app.name}';

      routes.add('/${app.name}');

      final appExists = await Directory(appDir).exists();
      if (!app.isEnable) {
        if (appExists) {
          await AppHelper.deleteDirectory(appDir);
        }
      } else {
        apps.add(app);
      }
    }

    setState(() {
      isLoading = false;
      // apps.removeWhere((key, value) => !value);
    });

    userToken = AppHelper.generateInternalToken();

    server = await startLocalWebServer(
      dirMiniApps,
      8080,
      routes: routes,
      validToken: userToken,
    );
  }

  @override
  void dispose() {
    super.dispose();
    server.close(force: true);
  }
}
