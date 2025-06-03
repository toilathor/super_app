import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptService {
  // Key và IV cố định (có thể đổi sau)
  static final _key =
      utf8.encode('my32lengthsupersecretnooneknows1'); // 32 bytes
  static final _iv = utf8.encode('8bytesiv12345678'); // 16 bytes

  static String encryptString(String plainText) {
    final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), _iv);
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    )..init(
        true,
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            params, null));
    final input = utf8.encode(plainText);
    final encrypted = cipher.process(Uint8List.fromList(input));
    return base64Encode(encrypted);
  }

  static String decryptString(String encryptedText) {
    final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), _iv);
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    )..init(
        false,
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            params, null));
    final input = base64Decode(encryptedText);
    final decrypted = cipher.process(Uint8List.fromList(input));
    return utf8.decode(decrypted);
  }

  static Future<void> encryptFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    try {
      final content = await file.readAsString();
      final encrypted = encryptString(content);
      final encryptedPath = '$filePath.enc';
      await File(encryptedPath).writeAsString(encrypted);
      await file.delete(); // Xóa file gốc
      print('Đã mã hóa file: $encryptedPath');
    } catch (e) {
      // Không phải file text, bỏ qua
      return;
    }
  }

  static Future<void> decryptFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    try {
      final content = await file.readAsString();
      final decrypted = decryptString(content);
      await file.writeAsString(decrypted);
    } catch (e) {
      // Không phải file text, bỏ qua
      return;
    }
  }

  static bool isEncryptTarget(String fileName) {
    return fileName.endsWith('.json.enc') ||
        fileName.endsWith('.js.enc') ||
        fileName.endsWith('.html.enc');
  }
}
