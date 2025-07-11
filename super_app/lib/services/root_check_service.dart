import 'package:root_checker_plus/root_checker_plus.dart';

class RootCheckService {
  RootCheckService._();

  static final RootCheckService I = RootCheckService._();

  /// Kiểm tra xem device có bị root/jailbreak không
  Future<bool> isDeviceRooted() async {
    try {
      // Cho Android
      final isRootChecker = await RootCheckerPlus.isRootChecker();
      if (isRootChecker == true) return true;

      // Cho iOS
      final isJailbreak = await RootCheckerPlus.isJailbreak();
      if (isJailbreak == true) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra xem device có bật developer mode không (Android only)
  Future<bool> isDeveloperModeEnabled() async {
    try {
      return await RootCheckerPlus.isDeveloperMode() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra root trên Android
  Future<bool> isAndroidRooted() async {
    try {
      return await RootCheckerPlus.isRootChecker() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra jailbreak trên iOS
  Future<bool> isIOSJailbroken() async {
    try {
      return await RootCheckerPlus.isJailbreak() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra xem device có an toàn không (tổng hợp tất cả các check)
  Future<bool> isDeviceSafe() async {
    try {
      final bool isRooted = await isDeviceRooted();
      final bool isDeveloperMode = await isDeveloperModeEnabled();

      return !isRooted && !isDeveloperMode;
    } catch (e) {
      return true;
    }
  }

  /// Lấy thông tin chi tiết về trạng thái bảo mật của device
  Future<Map<String, bool>> getSecurityStatus() async {
    try {
      return {
        'isRooted': await isDeviceRooted(),
        'isAndroidRooted': await isAndroidRooted(),
        'isIOSJailbroken': await isIOSJailbroken(),
        'isDeveloperMode': await isDeveloperModeEnabled(),
      };
    } catch (e) {
      return {
        'isRooted': false,
        'isAndroidRooted': false,
        'isIOSJailbroken': false,
        'isDeveloperMode': false,
      };
    }
  }

  /// Kiểm tra tất cả các phương pháp root detection có sẵn
  Future<Map<String, dynamic>> getDetailedRootInfo() async {
    try {
      final results = <String, dynamic>{};

      results['isRootChecker'] = await RootCheckerPlus.isRootChecker();
      results['isJailbreak'] = await RootCheckerPlus.isJailbreak();
      results['isDeveloperMode'] = await RootCheckerPlus.isDeveloperMode();

      return results;
    } catch (e) {
      return {
        'error': e.toString(),
        'isRootChecker': false,
        'isJailbreak': false,
        'isDeveloperMode': false,
      };
    }
  }
}
