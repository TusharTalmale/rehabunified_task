import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> ensureAnonymousLogin() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  String get uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }
}
