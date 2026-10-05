import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cultivatec_flutter/data/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email and password.
  /// Also creates Firestore profile with unique username.
  Future<User> registerUser({
    required String email,
    required String password,
    required String username,
    String fullName = '',
    Map<String, dynamic>? robotConfig,
    String robotName = '',
  }) async {
    final available = await _firestore.checkUsernameAvailable(username);
    if (!available) {
      throw FirebaseAuthException(
        code: 'username-taken',
        message: 'El nombre de usuario ya está en uso. Elige otro.',
      );
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;

    await user.updateDisplayName(username);

    await _firestore.createUserProfile(
      uid: user.uid,
      username: username,
      fullName: fullName,
      email: email,
      robotConfig: robotConfig,
      robotName: robotName,
    );

    return user;
  }

  /// Sign in with email/username and password.
  /// If identifier is not an email, look up email by username.
  Future<User> loginUser(String identifier, String password) async {
    String email = identifier;

    if (!identifier.contains('@')) {
      final foundEmail = await _firestore.getEmailByUsername(identifier);
      if (foundEmail == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No se encontró un usuario con ese nombre.',
        );
      }
      email = foundEmail;
    }

    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user!;
  }

  /// Sign in with Google. Works on web (popup) and mobile (google_sign_in).
  /// Creates a Firestore profile on first login so the rest of the app works.
  Future<User> signInWithGoogle() async {
    late final UserCredential userCredential;
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(code: 'cancelled', message: 'Inicio de sesión cancelado.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    final user = userCredential.user!;
    await _ensureProfile(user);
    return user;
  }

  /// Creates a Firestore profile for a freshly-authenticated user if none
  /// exists yet (e.g. first Google sign-in), generating a unique username.
  Future<void> _ensureProfile(User user) async {
    final existing = await _firestore.getUserProfile(user.uid);
    if (existing != null) return;

    final display = (user.displayName ?? '').trim();
    // Prefer the first name from the Google account; keep letters/accents.
    var base = (display.isNotEmpty ? display.split(' ').first : (user.email?.split('@').first ?? 'Explorador'))
        .replaceAll(RegExp(r'[^A-Za-zÀ-ÿ0-9_]'), '');
    if (base.isEmpty) base = 'Explorador';

    var username = base;
    int n = 0;
    while (!(await _firestore.checkUsernameAvailable(username))) {
      n++;
      username = '$base$n';
      if (n > 50) {
        username = '$base${DateTime.now().millisecondsSinceEpoch % 100000}';
        break;
      }
    }

    try {
      await _firestore.createUserProfile(
        uid: user.uid,
        username: username,
        fullName: display,
        email: user.email ?? '',
      );
    } catch (_) {
      // Fallback so the user's name isn't lost even if the batch write fails.
      await _firestore.updateUserProfile(user.uid, {
        'username': username,
        'usernameLower': username.toLowerCase(),
        'fullName': display.isEmpty ? username : display,
        'email': user.email ?? '',
      });
    }
  }

  /// Sign out.
  Future<void> logoutUser() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }
}
