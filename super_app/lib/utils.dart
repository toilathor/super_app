import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();

  static final I = Utils._();

  Future<bool> checkPermissionStatus(String permissionValue) async {
    try {
      switch (permissionValue.toLowerCase()) {
        case 'camera':
          return await Permission.camera.isGranted;
        case 'microphone':
          return await Permission.microphone.isGranted;
        case 'storage':
          if (Platform.isAndroid) {
            return await Permission.storage.isGranted;
          }
          return true;
        case 'location':
          return await Permission.location.isGranted;
        case 'contacts':
          return await Permission.contacts.isGranted;
        case 'photos':
          if (Platform.isIOS) {
            return await Permission.photos.isGranted;
          }
          return true;
        case 'notifications':
          return await Permission.notification.isGranted;
        case 'bluetooth':
          return await Permission.bluetooth.isGranted;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermission(String permissionValue) async {
    try {
      switch (permissionValue.toLowerCase()) {
        case 'camera':
          await Permission.camera.request();
          return true;
        case 'microphone':
          await Permission.microphone.request();
          return true;
        case 'storage':
          if (Platform.isAndroid) {
            await Permission.storage.request();
          }
          return true;
        case 'location':
          await Permission.location.request();
          return true;
        case 'contacts':
          await Permission.contacts.request();
          return true;
        case 'photos':
          if (Platform.isIOS) {
            await Permission.photos.request();
          }
          return true;
        case 'notifications':
          await Permission.notification.request();
          return true;
        case 'bluetooth':
          await Permission.bluetooth.request();
          return true;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  String getPermissionDescription(String permissionValue) {
    switch (permissionValue.toLowerCase()) {
      case 'camera':
        return 'Truy cập camera';
      case 'microphone':
        return 'Truy cập microphone';
      case 'storage':
        return 'Truy cập bộ nhớ';
      case 'geolocation':
        return 'Truy cập vị trí';
      case 'contacts':
        return 'Truy cập danh bạ';
      case 'photos':
        return 'Truy cập thư viện ảnh';
      case 'notifications':
        return 'Gửi thông báo';
      case 'bluetooth':
        return 'Truy cập Bluetooth';
      default:
        return permissionValue;
    }
  }
}
