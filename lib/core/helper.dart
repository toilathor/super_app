import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AppHelper {
  static Future<String?> downloadWithDio(String url, String fileName) async {
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/zips/$fileName';

    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Đang tải: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );

    return savePath;
  }

  static Future<void> deleteDirectory(String deletePath) {
    final directory = Directory(deletePath);
    if (directory.existsSync()) {
      return directory.delete(recursive: true);
    } else {
      return Future.value();
    }
  }

  static String generateInternalToken() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }
}
