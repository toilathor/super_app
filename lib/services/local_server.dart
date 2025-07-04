import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:flutter_super_app/services/encrypt_service.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

final customMimeTypeResolver = MimeTypeResolver()
  ..addExtension('js', 'application/javascript')
  ..addExtension('wasm', 'application/wasm')
  ..addExtension('json', 'application/json')
  ..addExtension('map', 'application/json')
  ..addExtension('svg', 'image/svg+xml')
  ..addExtension('ico', 'image/x-icon')
  ..addExtension('css', 'text/css')
  ..addExtension('html', 'text/html')
  ..addExtension('png', 'image/png')
  ..addExtension('jpg', 'image/jpeg')
  ..addExtension('jpeg', 'image/jpeg');

/// Start a static server from the copied web assets
Future<HttpServer> startLocalWebServer(
  String rootPath,
  int port, {
  required List<String> routes,
  String validToken = "",
}) async {
  final router = Router();

  for (final route in routes) {
    staticHandler(Request request) async {
      final path = request.url.path;
      final filePath = "$rootPath$route/$path";
      final filePathEnc = "$filePath.enc";
      if (EncryptService.isEncryptTarget(filePathEnc) &&
          await File(filePathEnc).exists()) {
        // Nếu là file mã hóa, giải mã trước khi trả về
        final encryptedContent = await File(filePathEnc).readAsString();
        final decryptedContent = EncryptService.decryptString(encryptedContent);
        final mimeType =
            customMimeTypeResolver.lookup(filePath) ?? 'text/plain';
        return Response.ok(decryptedContent,
            headers: {'content-type': mimeType});
      }
      // Nếu không, dùng static handler mặc định
      final handler = createStaticHandler(
        "$rootPath$route",
        defaultDocument: 'index.html',
        serveFilesOutsidePath: false,
        contentTypeResolver: customMimeTypeResolver,
      );
      return handler(request);
    }

    // Bọc handler bằng middleware trước khi mount
    final protectedHandler = Pipeline()
        .addMiddleware(_checkTokenForIndexOnly())
        .addHandler(staticHandler);

    router.mount(route, protectedHandler);
  }

  final server = await shelf_io.serve(
    router.call,
    'localhost',
    port,
  );

  return server;
}

Middleware _checkTokenForIndexOnly() {
  return (Handler innerHandler) {
    return (Request request) async {
      final path = request.url.path;

      // Cho phép favicon, JS, CSS, ảnh mà không cần token
      final allowedExtensions = [
        '.js',
        '.css',
        '.png',
        '.jpg',
        '.jpeg',
        '.svg',
        '.ico',
        '.webp'
      ];
      final isStaticFile = allowedExtensions.any((ext) => path.endsWith(ext));

      // Nếu là file tĩnh → bỏ qua token
      if (isStaticFile) {
        return await innerHandler(request);
      }

      // Nếu là index.html → kiểm tra token
      if (path.endsWith('index.html')) {
        final authHeader = request.headers['Authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.forbidden(
            'Missing or malformed Authorization header',
          );
        }

        final token = authHeader.substring(7);
        try {
          final jwt = JWT.verify(token, SecretKey(AppConstant.secretKey));
          // Optionally add payload to request context
          // final updatedRequest = request.change(context: {'jwt': jwt});
          // return await innerHandler(updatedRequest);

          return await innerHandler(request);
        } on JWTExpiredException {
          return Response.unauthorized('Token expired');
        } on JWTException catch (ex) {
          return Response.unauthorized('Invalid token: ${ex.message}');
        }
      }

      // Cho phép request tiếp tục
      return await innerHandler(request);
    };
  };
}
