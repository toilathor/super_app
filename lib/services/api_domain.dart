import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_super_app/core/constanst.dart';

class ApiDomainService {
  ApiDomainService._();

  static final ApiDomainService _instance = ApiDomainService._();

  // ..... TODO: GETTER ........................................................
  static ApiDomainService get I => _instance;

  // ..... TODO: METHODS .......................................................
  String createMiniAppAccessToken({
    required String miniAppId,
    required List<String> allowedDomains,
    Duration expiryDuration = const Duration(minutes: 30),
  }) {
    // 1. Hash domain list bằng SHA256
    final hashedDomains = allowedDomains
        .map((d) => sha256.convert(utf8.encode(d)).toString())
        .toList();

    // 2. Tạo payload JSON
    final payload = {
      'app': miniAppId,
      'exp': DateTime.now().add(expiryDuration).millisecondsSinceEpoch,
      'domains': hashedDomains,
    };

    // 3. Chuyển payload thành JSON và encode base64
    final jsonPayload = jsonEncode(payload);
    final base64Payload = base64.encode(utf8.encode(jsonPayload));

    // 4. Tạo chữ ký HMAC SHA256
    final hmac = Hmac(sha256, utf8.encode(AppConstant.apiDomainSecretKey));
    final signature = hmac.convert(utf8.encode(jsonPayload)).toString();

    // 5. Ghép token: base64.payload + . + signature
    return '$base64Payload.$signature';
  }

  bool verifyDomainFromToken(String token, String domain) {
    // 1. Split token thành payload và signature
    final parts = token.split('.');
    if (parts.length != 2) return false;

    final encodedPayload = parts[0];
    final signature = parts[1];

    // 2. Decode base64 payload
    final decodedPayloadJson = utf8.decode(base64.decode(encodedPayload));
    final payload = jsonDecode(decodedPayloadJson);

    // 3. Verify signature
    final hmac = Hmac(sha256, utf8.encode(AppConstant.apiDomainSecretKey));
    final expectedSignature =
        hmac.convert(utf8.encode(decodedPayloadJson)).toString();

    if (expectedSignature != signature) return false;

    // 4. Verify expiration
    final now = DateTime.now().millisecondsSinceEpoch;
    if (payload['exp'] is! int || payload['exp'] < now) return false;

    // 5. Verify domain hash
    final domainHash = sha256.convert(utf8.encode(domain)).toString();
    final List<dynamic> allowedDomains = payload['domains'];

    return allowedDomains.contains(domainHash);
  }
}
