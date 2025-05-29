import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/helper.dart';
import 'package:flutter_super_app/models/mini_app.dart';
import 'package:flutter_super_app/services/zip_service.dart';
import 'package:flutter_super_app/ui/inapp_webview_screen.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<MiniApp, bool> apps = {};

  bool isLoading = false;

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
      appBar: AppBar(),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: apps.length,
            itemBuilder: (_, int index) {
              return apps.keys.elementAt(index).isEnable
                  ? ListTile(
                      onTap: () async {
                        if (apps.values.elementAt(index)) {
                          final dirDoc =
                              await getApplicationDocumentsDirectory();
                          final dirMiniApps =
                              "${dirDoc.path}/${AppConstant.folderApps}";
                          final appDir =
                              '$dirMiniApps/${apps.keys.elementAt(index).name}';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InAppWebViewScreen(
                                appName: apps.keys.elementAt(index).name,
                                folder: appDir,
                              ),
                            ),
                          );
                        }
                      },
                      title: Text(apps.keys.elementAt(index).name),
                      leading: FlutterLogo(),
                      trailing: apps.values.elementAt(index)
                          ? GestureDetector(
                              child: Icon(Icons.remove_circle,
                                  color: Colors.black26),
                            )
                          : GestureDetector(
                              child:
                                  Icon(Icons.download, color: Colors.black26),
                              onTap: () => _downloadApp(
                                apps.keys.elementAt(index).link,
                                apps.keys.elementAt(index).name,
                              ),
                            ),
                    )
                  : SizedBox();
            },
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.new_releases_rounded),
        onPressed: () {

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

    for (final app in AppConstant.apps) {
      final appDir = '$dirMiniApps/${app.name}';
      final appExists = await Directory(appDir).exists();
      if (appExists) {
        apps[app] = true;
        if (!app.isEnable) {
          await AppHelper.deleteDirectory(appDir);
        } else {
          final versionFile = File('$appDir/version.json');
          if (await versionFile.exists()) {
            final versionContent = await versionFile.readAsString();
            final versionData =
                versionContent.isNotEmpty ? jsonDecode(versionContent) : null;
            final currentVersion = versionData["version"] ?? "";
            final versionSplit = currentVersion.split('.');
            final version = versionSplit.isNotEmpty
                ? int.parse(versionSplit[0]) +
                    int.parse(versionSplit[1]) +
                    int.parse(versionSplit[2])
                : 0;
            if (version > app.version) {
              await _downloadApp(app.link, app.name);
            }
          }
        }
      } else {
        apps[app] = false;
        if (app.isEnable) {
          await _downloadApp(app.link, app.name);
        }
      }
    }

    setState(() {
      isLoading = false;
      apps.removeWhere((key, value) => !value);
    });
  }

  Future<void> _downloadApp(String link, String name) async {
    final token = RootIsolateToken.instance;
    if (token == null) {
      print("Cannot get the RootIsolateToken");
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
      ),
    );

    final result = await receivePort.first as bool;
    if (result) {
      setState(() {
        apps[AppConstant.apps.firstWhere((element) => element.name == name)] =
            true;
      });
    }
  }
}

class _DownloadMessage {
  final String link;
  final String name;
  final SendPort sendPort;
  final RootIsolateToken token;

  _DownloadMessage({
    required this.link,
    required this.name,
    required this.sendPort,
    required this.token,
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
      await ZipService.extractZip(
        pathDownload,
        onZipSuccess: (path) {},
      );
      message.sendPort.send(true);
    } else {
      message.sendPort.send(false);
    }
  } catch (e) {
    message.sendPort.send(false);
  }
}
