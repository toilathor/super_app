import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageServiceKeys {
  static const accessToken = 'access_token';
}

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService I = SecureStorageService._();

  final storage = FlutterSecureStorage();

  // TODO: ..... ACCESS TOKEN START.............................................
  Future<void> saveToken(String token) async {
    await storage.write(
      key: SecureStorageServiceKeys.accessToken,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return await storage.read(key: SecureStorageServiceKeys.accessToken);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: SecureStorageServiceKeys.accessToken);
  }
// ..... ACCESS TOKEN END.....................................................
}
