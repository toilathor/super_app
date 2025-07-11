import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';

class AppHelper {
  // Public key của super app (hardcoded hoặc config)
  static const String publicPem =
      String.fromEnvironment("API_DOMAIN_RSA_PUBLIC_KEY");

  AppHelper();

  static bool verifyDomainFromToken({
    required String payloadJson,
    required String signatureBase64,
  }) {
    try {
      final publicKey = CryptoUtils.rsaPublicKeyFromPem(publicPem);
      final payloadBytes = utf8.encode(payloadJson);
      final signatureBytes = base64.decode(signatureBase64);

      return CryptoUtils.rsaVerify(
        publicKey,
        payloadBytes,
        signatureBytes,
        algorithm: 'SHA-256/ RSA',
      );
    } catch (e) {
      print('Verification error: $e');
      return false;
    }
  }
}
