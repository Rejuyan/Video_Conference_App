import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check if both camera and microphone permissions are granted
  static Future<bool> hasCameraAndMicPermissions() async {
    if (kIsWeb) return true;
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  /// Request camera and microphone permissions
  static Future<bool> requestCameraAndMicPermissions() async {
    if (kIsWeb) return true;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
  }

  /// Open application OS settings if permissions are permanently denied
  static Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }
}
