import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:path_provider/path_provider.dart';

class ZipService {
  static Future<String> extractZip(String zipPath,
      {required void Function(String path) onZipSuccess}) async {
    try {
      // Read the ZIP file from assets
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final extractPath = '${directory.path}/${AppConstant.folderApps}';

      // Create the directory if it doesn't exist
      await Directory(extractPath).create(recursive: true);

      // Extract the contents
      for (final file in archive) {
        final outFile = File('$extractPath/${file.name}');
        if (file.isFile) {
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      onZipSuccess.call(extractPath);
      File(zipPath).deleteSync(recursive: true);

      return extractPath;
    } catch (e) {
      print('Error extracting ZIP: $e');
      rethrow;
    }
  }
}
