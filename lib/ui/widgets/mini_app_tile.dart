import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/core/helper.dart';
import 'package:flutter_super_app/core/logger.dart';
import 'package:flutter_super_app/core/router.dart';
import 'package:flutter_super_app/models/mini_app.dart';
import 'package:flutter_super_app/services/zip_service.dart';
import 'package:flutter_super_app/ui/inapp_webview_screen.dart';
import 'package:flutter_super_app/ui/widgets/download_overlay.dart';
import 'package:path_provider/path_provider.dart';

class MiniAppTile extends StatefulWidget {
  const MiniAppTile({super.key, required this.miniApp});

  final MiniApp miniApp;

  @override
  State<MiniAppTile> createState() => _MiniAppTileState();
}

class _MiniAppTileState extends State<MiniAppTile> {
  bool downloading = false;
  ValueNotifier<double> progress = ValueNotifier(0);
  bool? appReady;
  late String appDir;

  @override
  void initState() {
    _checkApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      enableHapticFeedback: true,
      actions: [
        if (appReady == true)
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.delete,
            onPressed: () async {
              Navigator.pop(context);
              await AppHelper.deleteDirectory(appDir);
              _checkApp();
            },
            isDestructiveAction: true,
            child: Text("Delete"),
          ),
        CupertinoContextMenuAction(
          onPressed: () {
            // Check UPDATE
          },
          trailingIcon: CupertinoIcons.cloud_download,
          child: Text("Update"),
        ),
      ],
      child: Material(
        child: InkWell(
          onTap: _onPressMiniApp,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: ValueListenableBuilder(
                    valueListenable: progress,
                    builder: (_, progressValue, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: downloading || appReady != true
                                ? max(progressValue, 0.5)
                                : 1,
                            child: FlutterLogo(
                              size: 64,
                            ),
                          ),
                          if (appReady == false && !downloading)
                            Icon(CupertinoIcons.cloud_download),
                          if (downloading)
                            DownloadOverlay(
                              progress: progressValue,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Text(widget.miniApp.name)
            ],
          ),
        ),
      ),
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
        hash: hash,
      ),
    );

    receivePort.listen(
      (message) {
        if (message is bool) {
          setState(() {
            progress.value = 0;
            appReady = message;
            downloading = false;
          });

          if (!message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Cannot download app!"),
              ),
            );
          }
        } else if (message is double) {
          progress.value = message;
        }
      },
    );
  }

  Future<void> _onPressMiniApp() async {
    if (appReady == true) {
      Navigator.pushNamed(
        context,
        AppRoutes.miniApp,
        arguments: InAppWebViewScreenArgument(
          appName: widget.miniApp.name,
          folder: appDir,
        ),
      );
      return;
    } else if (appReady == false && widget.miniApp.isEnable && !downloading) {
      setState(() {
        downloading = true;
      });
      _downloadApp(
        widget.miniApp.link,
        widget.miniApp.name,
        widget.miniApp.checksum,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Cannot open app!"),
      ),
    );
  }

  Future<void> _checkApp() async {
    final dirDoc = await getApplicationDocumentsDirectory();
    final dirMiniApps = "${dirDoc.path}/${AppConstant.folderApps}";
    appDir = '$dirMiniApps/${widget.miniApp.name}';

    setState(() {
      appReady = Directory(appDir).existsSync();
    });
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
      onReceiveProgress: (received, total) {
        final progress = received / total;
        message.sendPort.send(progress);
      },
    );

    if (pathDownload != null) {
      await ZipService.extractZip(
        pathDownload,
        onZipSuccess: (path) {},
        hash: message.hash,
      );
      message.sendPort.send(true);
    } else {
      message.sendPort.send(false);
    }
  } catch (e) {
    message.sendPort.send(false);
    AppLogger.e(e);
  }
}
