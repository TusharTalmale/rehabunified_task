import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import '../controllers/call_controller.dart';
import '../controllers/session_controller.dart';
import '../models/session_model.dart';

class VideoCallScreen extends StatefulWidget {
  VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  final CallController callController = Get.find<CallController>();
  final SessionController sessionController = Get.find<SessionController>();

  @override
  void initState() {
    super.initState();
    callController.sessionId = Get.arguments;
    callController.start();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      callController.minimize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String sessionId = Get.arguments;
    callController.sessionId = sessionId;

    final session = sessionController.allSessions.firstWhere(
      (s) => s.sessionId == sessionId,
      orElse:
          () => SessionModel(
            sessionId: sessionId,
            title: 'Live Session',
            description: 'No description available',
            ownerName: 'Unknown Host',
            status: 'ongoing',
            startTime: DateTime.now(),
            durationSeconds: 0,
            awaitingCount: 0,
            joinedCount: 0,
            subscribers: [],
            joinedUsers: [],
          ),
    );

    // start timer once
    if (!callController.started) {
      callController.start();
    }

    return WillPopScope(
      onWillPop: () async {
        _minimizeCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              _liveBadge(),
              const SizedBox(width: 8),
              const Text('Live Session'),
            ],
          ),
        ),
        body: SafeArea(child: _mainContent(session)),
      ),
    );
  }

  Widget _mainContent(SessionModel session) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sessionInfo(session),
          const SizedBox(height: 16),
          _videoArea(),
          _controlBar(),
          const SizedBox(height: 12),
          _description(session),
          const SizedBox(height: 12),
          _timer(),
          const Spacer(),
          _endCallButton(session.sessionId),
        ],
      ),
    );
  }

  Widget _sessionInfo(SessionModel session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by ${session.ownerName}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _videoArea() {
    return Obx(() {
      return Stack(
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade800),
              color: Colors.grey.shade900,
            ),
            child: const Center(
              child: Icon(Icons.videocam, color: Colors.white, size: 80),
            ),
          ),

          // 👀 Self video preview
          if (callController.camOn.value &&
              callController.localRenderer.srcObject != null)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: RTCVideoView(callController.localRenderer, mirror: true),
              ),
            ),
        ],
      );
    });
  }

  Widget _description(SessionModel session) {
    return Text(
      session.description.isNotEmpty ? session.description : 'No description',
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _controlBar() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _iconButton(
            icon: callController.micOn.value ? Icons.mic : Icons.mic_off,
            active: callController.micOn.value,
            onTap: callController.toggleMic,
          ),
          const SizedBox(width: 20),

          const SizedBox(width: 20),
          _iconButton(
            icon:
                callController.camOn.value
                    ? Icons.videocam
                    : Icons.videocam_off,
            active: callController.camOn.value,
            onTap: callController.toggleCam,
          ),
          const SizedBox(width: 20),
          _iconButton(
            icon: Icons.picture_in_picture_alt,
            active: true,
            onTap: callController.minimize,
          ),
        ],
      );
    });
  }

  Widget _iconButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: active ? Colors.white : Colors.grey),
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _timer() {
    return Obx(() {
      return Center(
        child: Text(
          _formatTime(callController.seconds.value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _endCallButton(String sessionId) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () async {
          await sessionController.leave(sessionId);
                    Get.back();

        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          foregroundColor: Colors.red,
        ),
        child: const Text('End Session'),
      ),
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  void _minimizeCall() {
    callController.minimize();
    Get.back(); //  go back to Appointments
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
