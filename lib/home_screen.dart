import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_app/constanst.dart';
import 'package:flutter_super_app/helper.dart';
import 'package:flutter_super_app/local_server.dart';
import 'package:flutter_super_app/mini_app.dart';
import 'package:flutter_super_app/zip_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
                              builder: (_) => WebViewPage(
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

class WebViewPage extends StatefulWidget {
  final String? appName;
  final String? folder;

  const WebViewPage({super.key, this.appName, this.folder});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  final int _port = 8080;
  HttpServer? server;
  final String userToken = 'abc123xyz';

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _controller.addJavaScriptChannel(
              'ToFlutter',
              onMessageReceived: (JavaScriptMessage message) {
                final data = message.message;

                print("Received from Mini App: $data");
              },
            );
          },
        ),
      )
      ..setOnConsoleMessage(
        (message) {
          print("Console.log: ${message.message}");
        },
      );
    super.initState();
    _initWebApp();
  }

  Future<void> _initWebApp() async {
    final webFolder =
        widget.folder ?? await prepareWebAssets(widget.appName ?? "");
    server = await startLocalWebServer(webFolder, _port);
    _controller.loadRequest(Uri.parse('http://localhost:$_port'));
    _controller
      ..setBackgroundColor(Colors.white)
      ..platform.setOnPlatformPermissionRequest(
        (request) {
          request.grant();
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mini app: ${widget.appName}")),
      body: WebViewWidget(
        controller: _controller,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final script = "window.postMessage({token: '$userToken'}, '*');";
          _controller.runJavaScript(script);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    server?.close(force: true);
  }
}
