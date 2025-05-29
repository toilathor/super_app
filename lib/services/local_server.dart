import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// Start a static server from the copied web assets
Future<HttpServer> startLocalWebServer(
  String folderPath,
  int port, {
  String validToken = "",
}) async {
  final handler = createStaticHandler(
    folderPath,
    defaultDocument: 'index.html',
    serveFilesOutsidePath: false,
  );

  final pipeline = Pipeline()
    ..addMiddleware(_checkToken(validToken))
    ..addMiddleware(_fixMimeAnd403());

  final server =
      await shelf_io.serve(pipeline.addHandler(handler), 'localhost', port);

  print('Serving at http://localhost:$port');
  return server;
}

Middleware _checkToken(String validToken) {
  return (innerHandler) {
    return (request) async {
      final token = request.headers['X-Internal-Token'];
      if (token != validToken) {
        return Response.forbidden('Access Denied');
      }
      return innerHandler(request);
    };
  };
}

Middleware _fixMimeAnd403() {
  return (innerHandler) {
    return (request) async {
      final response = await innerHandler(request);

      // Nếu 403 thì trả lại 404 hoặc sửa lại header
      if (response.statusCode == 403 || response.statusCode == 404) {
        final path = request.requestedUri.path;

        if (path.endsWith(".js")) {
          final file = File("miniapp$path");
          if (await file.exists()) {
            final jsContent = await file.readAsString();
            return Response.ok(jsContent, headers: {
              'Content-Type': 'application/javascript',
            });
          }
        }
      }

      // Fix MIME
      final path = request.requestedUri.path;
      if (path.endsWith(".js")) {
        return response.change(headers: {
          ...response.headers,
          "Content-Type": "application/javascript"
        });
      }

      return response;
    };
  };
}
