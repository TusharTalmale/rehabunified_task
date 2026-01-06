import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../constants/session_status.dart';

class SessionController extends GetxController {
  final SessionService _service = SessionService();

  // ========================
  // Core State
  // ========================

  final RxList<SessionModel> allSessions = <SessionModel>[].obs;

  final RxBool isInitialLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxString errorMessage = ''.obs;

  // ========================
  // Filters & Search
  // ========================

  final RxString selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounce;
  StreamSubscription? _sessionSub;

  // ========================
  // Lifecycle
  // ========================

  @override
  void onInit() {
    super.onInit();
    loadInitial();
    startRealtime();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _sessionSub?.cancel();
    super.onClose();
  }

  // ========================
  // Fetch Logic
  // ========================

  Future<void> loadInitial() async {
    isInitialLoading.value = true;
    errorMessage.value = '';
    hasMore.value = true;

    _service.resetStatusPagination(selectedStatus.value);

    try {
      final data = await _service.fetchByStatus(
        status: selectedStatus.value,
        search: searchQuery.value,
        isNextPage: false,
      );

      allSessions.assignAll(data);
      hasMore.value = data.length == SessionService.pageSize;
    } catch (e) {
      errorMessage.value = _mapError(e);
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      final data = await _service.fetchByStatus(
        status: selectedStatus.value,
        search: searchQuery.value,
        isNextPage: true,
      );

      if (data.isEmpty) {
        hasMore.value = false;
      } else {
        allSessions.addAll(data);
        hasMore.value = data.length == SessionService.pageSize;
      }
    } catch (e) {
      errorMessage.value = _mapError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void startRealtime() {
    _sessionSub?.cancel();

    if (searchQuery.isNotEmpty) return;

    _sessionSub = _service.listenByStatus(selectedStatus.value).listen((data) {
      allSessions.assignAll(data);

      for (var session in data) {
        _service.autoUpdateStatus(session);
      }
    });
  }

  // ========================
  // Filters & Search
  // ========================

  void changeStatus(String status) {
    if (selectedStatus.value == status) return;

    selectedStatus.value = status;
    allSessions.clear();
    startRealtime();
    loadInitial();
  }

  void updateSearch(String query) {
    searchQuery.value = query;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _service.resetStatusPagination(selectedStatus.value);
      loadInitial();

      if (query.isEmpty) {
        startRealtime();
      }
    });
  }

  // ========================
  // User Actions (Safe)
  // ========================

  Future<void> subscribe(SessionModel session) async {
    final index = allSessions.indexWhere(
      (s) => s.sessionId == session.sessionId,
    );
    if (index == -1) return;

    final original = allSessions[index];
    allSessions[index] = original.copyWith(
      awaitingCount: original.awaitingCount + 1,
      subscribers: [...original.subscribers, 'temp'],
    );

    await _safeAction(
      () => _service.subscribe(session),
      rollback: () {
        // 🔹 Re-find index to avoid stale state bugs
        final idx = allSessions.indexWhere(
          (s) => s.sessionId == session.sessionId,
        );
        if (idx != -1) {
          allSessions[idx] = original;
        }
      },
    );
  }

  Future<void> unsubscribe(SessionModel session) async {
    final index = allSessions.indexWhere(
      (s) => s.sessionId == session.sessionId,
    );
    if (index == -1) return;

    final original = allSessions[index];
    allSessions[index] = original.copyWith(
      awaitingCount: (original.awaitingCount - 1).clamp(0, 9999),
    );

    await _safeAction(
      () => _service.unsubscribe(session),
      rollback: () {
        final idx = allSessions.indexWhere(
          (s) => s.sessionId == session.sessionId,
        );
        if (idx != -1) {
          allSessions[idx] = original;
        }
      },
    );
  }

  Future<void> join(SessionModel session) async {
    final index = allSessions.indexWhere(
      (s) => s.sessionId == session.sessionId,
    );
    if (index == -1) return;

    final original = allSessions[index];
    // 🔥 Optimistic Update
    allSessions[index] = original.copyWith(
      joinedCount: original.joinedCount + 1,
      // Assuming user was subscribed, decrement awaiting
      awaitingCount: (original.awaitingCount - 1).clamp(0, 9999),
    );

    await _safeAction(
      () => _service.join(session),
      rollback: () {
        final idx = allSessions.indexWhere(
          (s) => s.sessionId == session.sessionId,
        );
        if (idx != -1) {
          allSessions[idx] = original;
        }
      },
    );
  }

  Future<void> leave(String sessionId) async {
    final index = allSessions.indexWhere((s) => s.sessionId == sessionId);
    if (index == -1) return;

    final original = allSessions[index];
    // 🔥 Optimistic Update
    allSessions[index] = original.copyWith(
      joinedCount: (original.joinedCount - 1).clamp(0, 9999),
    );

    await _safeAction(
      () => _service.leaveSession(sessionId),
      rollback: () {
        final idx = allSessions.indexWhere((s) => s.sessionId == sessionId);
        if (idx != -1) {
          allSessions[idx] = original;
        }
      },
    );
  }

  Future<void> _safeAction(
    Future<void> Function() action, {
    VoidCallback? rollback,
  }) async {
    try {
      await action();
    } catch (e) {
      // 🔹 Wrap rollback to ensure snackbar still shows if rollback fails
      if (rollback != null) {
        try {
          rollback();
        } catch (_) {}
      }

      // 🔹 Check context to prevent crashes in tests/background
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          _mapError(e),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // ========================
  // Derived Lists (UI Ready)
  // ========================

  List<SessionModel> get upcomingSessions =>
      allSessions.where((s) => s.status == SessionStatus.upcoming).toList();

  List<SessionModel> get ongoingSessions =>
      allSessions.where((s) => s.status == SessionStatus.ongoing).toList();

  List<SessionModel> get completedSessions =>
      allSessions.where((s) => s.status == SessionStatus.completed).toList();

  // ========================
  // Helpers
  // ========================

  bool get isEmptyState =>
      !isInitialLoading.value && allSessions.isEmpty && errorMessage.isEmpty;

  String _mapError(Object e) {
    final msg = e.toString();

    if (msg.contains('index')) {
      return 'Server index not ready.';
    }
    if (msg.contains('permission-denied')) {
      return 'Permission denied.';
    }
    if (msg.contains('network')) {
      return 'No internet connection.';
    }

    return msg;
  }
}
