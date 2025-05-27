import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

Future<String> prepareWebAssets(String appName) async {
  final tempDir =
      await Directory.systemTemp.createTemp('flutter_web_assets_$appName');
  final assetBasePath = 'assets/$appName/';

  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

  for (final entry in manifestMap.entries) {
    final String assetPath = entry.key;

    if (assetPath.startsWith(assetBasePath) &&
        !assetPath.contains('.DS_Store') &&
        !assetPath.contains('.last_build_id')) {
      final data = await rootBundle.load(assetPath);
      final relativePath = assetPath.replaceFirst(assetBasePath, '');
      final file = File(p.join(tempDir.path, relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data.buffer.asUint8List());
    }
  }

  return tempDir.path;
}

/// Start a static server from the copied web assets
Future<HttpServer> startLocalWebServer(String folderPath, int port) async {
  final handler = createStaticHandler(
    folderPath,
    defaultDocument: 'index.html',
    serveFilesOutsidePath: false,
  );

  final server = await shelf_io.serve(handler, 'localhost', port);
  print('Serving at http://localhost:$port');
  return server;
}
