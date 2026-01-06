import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../constants/firestore_constants.dart';
import 'auth_service.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  static const int pageSize = 10;
  String get currentUserId => _authService.uid;

  // DocumentSnapshot? _lastDoc;
  final Map<String, DocumentSnapshot?> _lastDocs = {
    'all': null,
    'upcoming': null,
    'ongoing': null,
    'completed': null,
  };


  Future<List<SessionModel>> fetchByStatus({
    required String status,
    String? search,
    bool isNextPage = false,
  }) async {
    Query query = _firestore.collection(FirestoreConstants.sessions);

    // Status filter (only if not "all")
    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    // Search filter (prefix search)
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      query = query
          .where('title_lowercase', isGreaterThanOrEqualTo: q)
          .where('title_lowercase', isLessThanOrEqualTo: '$q\uf8ff');
    }

    
    query = query.orderBy('startTime');

    // Pagination
    final lastDoc = _lastDocs[status];
    if (isNextPage && lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.limit(pageSize).get();

    if (snap.docs.isNotEmpty) {
      _lastDocs[status] = snap.docs.last;
    } else if (!isNextPage) {
      _lastDocs[status] = null;
    }

    return snap.docs.map(SessionModel.fromFirestore).toList();
  }

  /// 🔹 Real-time Listener
  Stream<List<SessionModel>> listenByStatus(String status) {
    Query query = _firestore.collection(FirestoreConstants.sessions);

    if (status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    return query
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(SessionModel.fromFirestore).toList());
  }

  Future<void> autoUpdateStatus(SessionModel session) async {
    final now = DateTime.now();
    final ref = _firestore
        .collection(FirestoreConstants.sessions)
        .doc(session.sessionId);

    if (session.status == 'upcoming' && now.isAfter(session.startTime)) {
      await ref.update({'status': 'ongoing'});
    }

    if (session.status == 'ongoing') {
      final endTime = session.startTime.add(
        Duration(seconds: session.durationSeconds),
      );
      if (now.isAfter(endTime)) {
        await ref.update({'status': 'completed'});
      }
    }
  }

  // ========================
  // RESET
  // ========================

  void resetStatusPagination(String status) {
    _lastDocs[status] = null;
  }

  void resetAllPagination() {
    for (final key in _lastDocs.keys) {
      _lastDocs[key] = null;
    }
  }

  /// Subscribe to an upcoming session
  Future<void> subscribe(SessionModel session) async {
    final uid = _authService.uid;
    final ref = _firestore
        .collection(FirestoreConstants.sessions)
        .doc(session.sessionId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;

      final subs = List<String>.from(data['subscribers'] ?? []);
      if (subs.contains(uid)) return;

      subs.add(uid);

      tx.update(ref, {
        'subscribers': subs,
        'awaitingCount': FieldValue.increment(1),
      });
    });
  }

  /// Unsubscribe
  Future<void> unsubscribe(SessionModel session) async {
    final uid = _authService.uid;
    final ref = _firestore
        .collection(FirestoreConstants.sessions)
        .doc(session.sessionId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;

      final subs = List<String>.from(data['subscribers'] ?? []);
      if (!subs.contains(uid)) return;

      subs.remove(uid);

      tx.update(ref, {
        'subscribers': subs,
        'awaitingCount': FieldValue.increment(-1),
      });
    });
  }

  Future<void> join(SessionModel session) async {
    final uid = _authService.uid;
    final ref = _firestore
        .collection(FirestoreConstants.sessions)
        .doc(session.sessionId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;

      final joined = List<String>.from(data['joinedUsers'] ?? []);
      final subs = List<String>.from(data['subscribers'] ?? []);

      if (joined.contains(uid)) return;

      joined.add(uid);
      if (subs.contains(uid)) subs.remove(uid);

      tx.update(ref, {
        'joinedUsers': joined,
        'subscribers': subs,
        'joinedCount': FieldValue.increment(1),
        if (subs.contains(uid)) 'awaitingCount': FieldValue.increment(-1),
      });
    });
  }

  Future<void> leaveSession(String sessionId) async {
    final uid = _authService.uid;
    final ref = _firestore
        .collection(FirestoreConstants.sessions)
        .doc(sessionId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;

      final joined = List<String>.from(data['joinedUsers'] ?? []);
      if (!joined.contains(uid)) return;

      joined.remove(uid);

      tx.update(ref, {
        'joinedUsers': joined,
        'joinedCount': FieldValue.increment(-1),
      });
    });
  }
}
