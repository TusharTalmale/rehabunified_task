import 'dart:async';
import 'dart:ui';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class CallController extends GetxController {
  final seconds = 0.obs;
  var sessionId = '';

  final minimized = false.obs;
  final expanded = true.obs;

  final micOn = true.obs;
  final camOn = true.obs;

  final offset = Offset(16, 120).obs;

  late RTCVideoRenderer localRenderer;
  MediaStream? localStream;

  bool started = false;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    localRenderer = RTCVideoRenderer();
    localRenderer.initialize();
    _initCamera();
  }

Future<void> _initCamera() async {
  try {
    localStream = await webrtc.navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user', // front camera
      },
    });

    localRenderer.srcObject = localStream;
  } catch (e) {
    print('Camera init error: $e');
  }
}



  void start() {
    started = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds.value++;
    });
  }

  void stop() {
    _timer?.cancel();
    // localStream?.dispose();
    localRenderer.dispose();

    localRenderer = RTCVideoRenderer();
    localRenderer.initialize();
    if (localStream != null) {
      localRenderer.srcObject = localStream;
    }

    seconds.value = 0;
    minimized.value = false;
    expanded.value = true;
    started = false;
  }

  void toggleMic() {
    micOn.toggle();
    localStream?.getAudioTracks().forEach((t) => t.enabled = micOn.value);
  }

  void toggleCam() {
    camOn.toggle();
    localStream?.getVideoTracks().forEach((t) => t.enabled = camOn.value);
  }

  void minimize() {
    minimized.value = true;
    expanded.value = false;
  }

  void expand() {
    minimized.value = false;
    expanded.value = true;

  }
  void endCall() {
    _timer?.cancel();
    _timer = null;

    localStream?.getTracks().forEach((t) => t.stop());
    localStream?.dispose();
    localStream = null;

    localRenderer.srcObject = null;
    localRenderer.dispose();

    seconds.value = 0;
    minimized.value = false;
    expanded.value = true;
    started = false;
  }
}
