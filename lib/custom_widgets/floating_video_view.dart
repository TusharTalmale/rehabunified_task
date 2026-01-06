import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rehabunified_task/screens/video_call_screen.dart';
import '../controllers/call_controller.dart';

class FloatingVideoView extends StatelessWidget {
  FloatingVideoView({super.key, required this.onClose});

  final VoidCallback onClose;
  final CallController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.minimized.value) return const SizedBox();

      return Positioned(
        right: controller.offset.value.dx,
        bottom: controller.offset.value.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            controller.offset.value += details.delta;
          },
          child: Container(
            width: 160,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.videocam, color: Colors.white)),

                // ❌ Close
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                // 📌 Expand
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      controller.expand();
                      Get.to(() => VideoCallScreen());
                    },
                    child: const Icon(
                      Icons.open_in_full,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
