import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rehabunified_task/constants/session_status.dart';
import 'package:rehabunified_task/controllers/session_controller.dart';
import 'package:rehabunified_task/custom_widgets/highlight_text.dart';
import 'package:rehabunified_task/models/session_model.dart';
import 'package:rehabunified_task/utils/permission_utils.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final SessionController controller;

  const SessionCard({
    super.key,
    required this.session,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 6),
            _description(),
            const SizedBox(height: 10),
            _countsRow(),
            const SizedBox(height: 14),
            _buildActions(context),
          ],
        ),
      );
    });
  }

  /// 🔹 Title + Status badge
  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: HighlightText(
            text: session.title,
            query: controller.searchQuery.value,
            normalStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        _statusChip(),
      ],
    );
  }

  Widget _description() {
    return Text(
      session.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey.shade700),
    );
  }

  Widget _countsRow() {
    return Row(
      children: [
        _countItem('Awaiting', session.awaitingCount),
        const SizedBox(width: 16),
        _countItem('Joined', session.joinedCount),
      ],
    );
  }

  Widget _countItem(String label, int value) {
    return Row(
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  /// 🔹 Status chip
  Widget _statusChip() {
    Color color;
    String text;

    switch (session.status) {
      case SessionStatus.upcoming:
        color = Colors.orange;
        text = 'Upcoming';
        break;
      case SessionStatus.ongoing:
        color = Colors.green;
        text = 'Live';
        break;
      default:
        color = Colors.grey;
        text = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🔹 Actions based on status
  Widget _buildActions(BuildContext context) {
    if (session.status == SessionStatus.upcoming) {
      return _primaryButton(
        text: 'Subscribe',
        onTap: () => controller.subscribe(session),
      );
    }

    if (session.status == SessionStatus.ongoing) {
      return _primaryButton(
        text: 'Join Session',
        onTap: () {
          PermissionSheet.show(
            onGranted: () async {
              await controller.join(session);

              Get.toNamed('/video-call', arguments: session.sessionId);
            },
          );
        },
      );
    }

    if (session.status == SessionStatus.completed) {
      return _secondaryButton();
    }

    return Container();
  }

  Widget _secondaryButton() {
    return const Align(
      alignment: Alignment.centerRight,
      child: Text('Session Completed', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class PermissionSheet {
  static void show({required Future<void> Function() onGranted}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            const Text(
              'Camera & Microphone Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'To join this live session, we need access to your camera and microphone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      final granted = await PermissionUtils.checkCameraAndMic();
                      if (granted) {
                        await onGranted();
                      }
                    },
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
