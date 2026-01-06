import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rehabunified_task/controllers/call_controller.dart';
import 'package:rehabunified_task/custom_widgets/floating_video_view.dart';
import 'package:rehabunified_task/custom_widgets/session_card_skeleton.dart';
import '../controllers/session_controller.dart';
import '../custom_widgets/session_card.dart';

class AppointmentsScreen extends StatelessWidget {
  AppointmentsScreen({super.key});

  final SessionController controller = Get.put(SessionController());
  final CallController callController = Get.put(CallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sessions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: _buildTabs(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _SearchBar(controller: controller), // 👈 OUTSIDE Obx
              Expanded(child: Obx(() => _buildBody())),
            ],
          ),
          FloatingVideoView(
            onClose: () {
              callController.stop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isInitialLoading.value) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const SessionCardSkeleton(),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return _ErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.changeStatus,
      );
    }

    if (controller.allSessions.isEmpty) {
      return const _EmptyState();
    }

    return _SessionList(controller: controller);
  }

  PreferredSizeWidget _buildTabs() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Obx(() {
        return Row(
          children: [
            _TabItem(
              label: 'All',
              selected: controller.selectedStatus.value == 'all',
              onTap: () => controller.changeStatus('all'),
            ),
            _TabItem(
              label: 'Upcoming',
              selected: controller.selectedStatus.value == 'upcoming',
              onTap: () => controller.changeStatus('upcoming'),
            ),
            _TabItem(
              label: 'Live',
              selected: controller.selectedStatus.value == 'ongoing',
              onTap: () => controller.changeStatus('ongoing'),
            ),
            _TabItem(
              label: 'Completed',
              selected: controller.selectedStatus.value == 'completed',
              onTap: () => controller.changeStatus('completed'),
            ),
          ],
        );
      }),
    );
  }
}

class _SessionList extends StatelessWidget {
  final SessionController controller;

  const _SessionList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh:
          () async => controller.changeStatus(controller.selectedStatus.value),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount:
              controller.allSessions.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.allSessions.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final session = controller.allSessions[index];
            return SessionCard(session: session, controller: controller);
          },
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final SessionController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: controller.updateSearch,
        decoration: InputDecoration(
          hintText: 'Search sessions...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No sessions found', style: TextStyle(color: Colors.grey)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Function(String) onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => onRetry('all'),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
