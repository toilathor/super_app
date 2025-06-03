import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_super_app/core/constanst.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_super_app/services/encrypt_service.dart';

class ZipService {
  static Future<String> extractZip(String zipPath,
      {required void Function(String path) onZipSuccess,
      required String hash}) async {
    try {
      // Read the ZIP file from assets
      final bytes = File(zipPath).readAsBytesSync();

      // Calculate MD5 hash of the ZIP file
      final calculatedHash = md5.convert(bytes).toString();

      // Verify hash matches
      if (calculatedHash != hash) {
        throw Exception(
            'Hash verification failed. Expected: $hash, Got: $calculatedHash');
      }

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

      // Mã hóa các file .json, .js, .html sau khi extract
      await _encryptExtractedFiles(extractPath);

      onZipSuccess.call(extractPath);
      File(zipPath).deleteSync(recursive: true);

      return extractPath;
    } catch (e) {
      print('Error extracting ZIP: $e');
      rethrow;
    }
  }

  static Future<void> _encryptExtractedFiles(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        // Bỏ qua file ẩn của macOS và file đã mã hóa
        if (entity.path.contains('__MACOSX') || fileName.startsWith('._') || fileName.endsWith('.enc')) continue;
        if (fileName.endsWith('.json') || fileName.endsWith('.js') || fileName.endsWith('.html')) {
          await EncryptService.encryptFile(entity.path);
        }
      }
    }
  }
}
