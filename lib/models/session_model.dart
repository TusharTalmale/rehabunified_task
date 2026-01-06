import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  /// Document ID
  final String sessionId;

  /// Display info
  final String title;
  final String description;
  final String ownerName;

  /// Session lifecycle
  /// upcoming | ongoing | completed
  final String status;

  /// Timing
  final DateTime startTime;
  final int durationSeconds;

  /// Participation
  final int awaitingCount;
  final int joinedCount;

  /// Subscribers (for notify feature)
  /// Stores anonymous user UIDs
  final List<String> subscribers;
  final List<String> joinedUsers;

  SessionModel({
    required this.sessionId,
    required this.title,
    required this.description,
    required this.ownerName,
    required this.status,
    required this.startTime,
    required this.durationSeconds,
    required this.awaitingCount,
    required this.joinedCount,
    required this.subscribers,
    required this.joinedUsers,
  });

  /// 🔹 Firestore → Model
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SessionModel(
      sessionId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'upcoming',
      startTime: (data['startTime'] as Timestamp).toDate(),
      durationSeconds: data['durationSeconds'] ?? 0,
      awaitingCount: data['awaitingCount'] ?? 0,
      joinedCount: data['joinedCount'] ?? 0,
      subscribers: List<String>.from(data['subscribers'] ?? []),
      joinedUsers: List<String>.from(data['joinedUsers'] ?? []),
    );
  }

  /// 🔹 Firestore updates (safe partial updates)

  /// When user subscribes / unsubscribes
  static Map<String, dynamic> subscriptionUpdate({
    required List<String> subscribers,
    required int awaitingCount,
  }) {
    return {'subscribers': subscribers, 'awaitingCount': awaitingCount};
  }

  /// When user joins a session
  static Map<String, dynamic> joinUpdate({
    required int awaitingCount,
    required int joinedCount,
    required String status,
  }) {
    return {
      'awaitingCount': awaitingCount,
      'joinedCount': joinedCount,
      'status': status, // usually "ongoing"
    };
  }

  /// When session duration updates
  static Map<String, dynamic> durationUpdate(int seconds) {
    return {'durationSeconds': seconds};
  }

  bool isSubscribed(String uid) => subscribers.contains(uid);
  bool isJoined(String uid) => joinedUsers.contains(uid);

  /// 🔹 CopyWith for Optimistic UI
  SessionModel copyWith({
    String? sessionId,
    String? title,
    String? description,
    String? ownerName,
    String? status,
    DateTime? startTime,
    int? durationSeconds,
    int? awaitingCount,
    int? joinedCount,
    List<String>? subscribers,
    List<String>? joinedUsers,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      awaitingCount: awaitingCount ?? this.awaitingCount,
      joinedCount: joinedCount ?? this.joinedCount,
      subscribers: subscribers ?? this.subscribers,
      joinedUsers: joinedUsers ?? this.joinedUsers,
    );
  }
}
