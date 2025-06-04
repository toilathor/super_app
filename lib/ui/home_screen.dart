import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/helper.dart';
import 'package:flutter_super_app/core/router.dart';
import 'package:flutter_super_app/models/mini_app.dart';
import 'package:flutter_super_app/services/local_server.dart';
import 'package:flutter_super_app/services/secure_storage_service.dart';
import 'package:flutter_super_app/services/zip_service.dart';
import 'package:flutter_super_app/ui/widgets/mini_app_tile.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<MiniApp, bool> apps = {};

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
            onPressed: _logout,
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
            miniApp: apps.keys.elementAt(index),
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
      if (appExists) {
        apps[app] = true;
        if (!app.isEnable) {
          await AppHelper.deleteDirectory(appDir);
        } else {
          app.setNeedDownload(false);
          final url =
              'https://api.github.com/repos/toilathor/${app.name}/branches/master';

          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final currentHash = data['commit']['sha'];
            print('sha of ${app.name} is $currentHash');
            if (currentHash != app.gitHash) {
              await _downloadApp(app.link, app.name, app.checksum);
              app.setNeedDownload(false);
            }
          }
        }
      } else {
        apps[app] = false;
        if (app.isEnable && !app.needDownload) {
          await _downloadApp(app.link, app.name, app.checksum);
          app.setNeedDownload(false);
        }
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

  Future<void> _downloadApp(String link, String name, String hash) async {
    final token = RootIsolateToken.instance;
    if (token == null) {
      return;
    }
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _downloadAndExtract,
      _DownloadMessage(
          link: link,
          name: name,
          sendPort: receivePort.sendPort,
          token: token,
          hash: hash),
    );

    final result = await receivePort.first as bool;
    if (result) {
      setState(() {
        apps[AppConstant.apps.firstWhere((element) => element.name == name)] =
            true;
      });
    }
  }

  Future<void> _logout() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );

    await SecureStorageService.I.deleteToken();
  }

  @override
  void dispose() {
    super.dispose();
    server.close(force: true);
  }
}

class _DownloadMessage {
  final String link;
  final String name;
  final SendPort sendPort;
  final RootIsolateToken token;
  final String hash;

  _DownloadMessage({
    required this.link,
    required this.name,
    required this.sendPort,
    required this.token,
    required this.hash,
  });
}

final token = RootIsolateToken.instance;

Future<void> _downloadAndExtract(_DownloadMessage message) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.token);
  try {
    final pathDownload = await AppHelper.downloadWithDio(
      message.link,
      "${message.name}.zip",
    );

    if (pathDownload != null) {
      await ZipService.extractZip(pathDownload,
          onZipSuccess: (path) {}, hash: message.hash);
      message.sendPort.send(true);
    } else {
      message.sendPort.send(false);
    }
  } catch (e) {
    message.sendPort.send(false);
  }
}
