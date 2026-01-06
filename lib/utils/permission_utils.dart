import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkCameraAndMic() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      return true;
    }

    // If user permanently denied, open settings
    if (cameraStatus.isPermanentlyDenied ||
        micStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
