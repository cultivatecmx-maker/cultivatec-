import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cultivatec_flutter/data/services/auth_service.dart';
import 'package:cultivatec_flutter/data/services/firestore_service.dart';
import 'package:cultivatec_flutter/data/models/user_profile.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';
import 'package:cultivatec_flutter/data/models/module_models.dart';
import 'package:cultivatec_flutter/core/utils/celebrations.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  UserProfile? _profile;
  Map<String, dynamic> _userScores = {};
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;
  // Solo es verdadero hasta que Firebase resuelve la sesión por primera vez.
  // El router usa ESTE valor (no isLoading) para mostrar la pantalla de carga,
  // así el formulario de acceso no se destruye mientras se inicia sesión.
  bool _initializing = true;
  String? _error;
  bool _onboardingDone = false;

  StreamSubscription? _profileSub;
  StreamSubscription? _scoresSub;
  StreamSubscription? _requestsSub;

  // Getters
  User? get user => _user;
  UserProfile? get profile => _profile;
  Map<String, dynamic> get userScores => _userScores;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  bool get isInitializing => _initializing;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get hasProfile => _profile != null;
  bool get onboardingDone => _onboardingDone;
  LevelInfo get levelInfo => calculateLevel(_profile?.totalPoints ?? 0);
  bool get isAdmin => _firestoreService.isAdminEmail(_profile?.email);

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _listenToProfile(user.uid);
        _listenToScores(user.uid);
        _listenToRequests(user.uid);
        _checkStreak(user.uid);
        _firestoreService.syncFriendsCount(user.uid);
      } else {
        _cancelSubscriptions();
        _profile = null;
        _userScores = {};
        _pendingRequests = [];
        _onboardingDone = false;
        CelebrationService.clear();
      }
      _isLoading = false;
      _initializing = false;
      notifyListeners();
    });
  }

  void _listenToProfile(String uid) {
    _profileSub?.cancel();
    _profileSub = _firestoreService.onUserProfileChange(uid).listen((profile) {
      final previous = _profile;
      _profile = profile;
      if (profile != null) {
        _onboardingDone = profile.robotConfig != null;
        // Solo celebramos cambios DESPUÉS de la primera carga del perfil.
        if (previous != null && previous.uid == profile.uid) {
          _detectCelebrations(previous, profile);
        }
      }
      notifyListeners();
    });
  }

  /// Compara el perfil anterior con el nuevo y encola celebraciones
  /// (subida de nivel y logros nuevos).
  void _detectCelebrations(UserProfile before, UserProfile after) {
    final oldLevel = calculateLevel(before.totalPoints).level;
    final newInfo = calculateLevel(after.totalPoints);
    if (newInfo.level > oldLevel) {
      CelebrationService.push(Celebration(
        kind: CelebrationKind.levelUp,
        title: '¡Subiste al nivel ${newInfo.level}!',
        subtitle: newInfo.title,
        number: newInfo.level,
      ));
    }

    final known = before.achievementsUnlocked.toSet();
    for (final id in after.achievementsUnlocked) {
      if (known.contains(id)) continue;
      final matches = allAchievements.where((a) => a.id == id);
      if (matches.isEmpty) continue;
      final a = matches.first;
      CelebrationService.push(Celebration(
        kind: CelebrationKind.achievement,
        title: '¡Nuevo logro!',
        subtitle: '${a.name} · ${a.description}',
      ));
    }
  }

  void _listenToScores(String uid) {
    _scoresSub?.cancel();
    _scoresSub = _firestoreService.onUserScoresChange(uid).listen((scores) {
      _userScores = scores;
      notifyListeners();
    });
  }

  void _listenToRequests(String uid) {
    _requestsSub?.cancel();
    _requestsSub = _firestoreService.onPendingRequestsChange(uid).listen((requests) {
      _pendingRequests = requests;
      notifyListeners();
    });
  }

  Future<void> _checkStreak(String uid) async {
    try {
      await _firestoreService.checkAndUpdateStreak(uid);
    } catch (_) {}
  }

  void _cancelSubscriptions() {
    _profileSub?.cancel();
    _scoresSub?.cancel();
    _requestsSub?.cancel();
  }

  // Auth actions
  Future<void> login(String identifier, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.loginUser(identifier, password);
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
    } catch (_) {
      _error = 'Algo salió mal. Inténtalo de nuevo en un momento.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String fullName = '',
    Map<String, dynamic>? robotConfig,
    String robotName = '',
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerUser(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        robotConfig: robotConfig,
        robotName: robotName,
      );
      // Correo de verificación (no bloquea el acceso si falla).
      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
    } catch (_) {
      _error = 'Algo salió mal. Inténtalo de nuevo en un momento.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'cancelled' && e.code != 'popup-closed-by-user') {
        _error = _mapAuthError(e.code);
      }
    } catch (_) {
      _error = 'Algo salió mal. Inténtalo de nuevo en un momento.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unlockAchievement(String id) async {
    if (_user == null) return;
    if (_profile?.achievementsUnlocked.contains(id) ?? false) return;
    try {
      await _firestoreService.unlockAchievement(_user!.uid, id);
    } catch (_) {}
  }

  Future<void> unlockSkin(String skinId) async {
    if (_user == null) return;
    if (_profile?.unlockedSkins.contains(skinId) ?? false) return;
    try {
      final currentSkins = List<String>.from(_profile?.unlockedSkins ?? []);
      currentSkins.add(skinId);
      await updateProfile({'unlockedSkins': currentSkins});
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authService.logoutUser();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _firestoreService.updateUserProfile(_user!.uid, data);
    if (data.containsKey('robotConfig')) {
      _onboardingDone = true;
      notifyListeners();
    }
  }

  Future<void> saveScore(String moduleId, Map<String, dynamic> scoreData) async {
    if (_user == null) return;
    await _firestoreService.saveModuleScore(_user!.uid, moduleId, scoreData);
  }

  Future<void> syncStats(Map<String, dynamic> statsUpdate) async {
    if (_user == null) return;
    // Toda la XP ganada cuenta para la meta diaria.
    final pts = statsUpdate['addPoints'];
    if (pts is int && DailyGoalService.addXp(pts)) {
      CelebrationService.push(Celebration(
        kind: CelebrationKind.dailyGoal,
        title: '¡Meta diaria cumplida!',
        subtitle: 'Ganaste ${DailyGoalService.goalXp.value} XP hoy. ¡Así se hace, inventor!',
      ));
    }
    await _firestoreService.syncUserStats(_user!.uid, statsUpdate);
  }

  // Helper: check if module is completed (>= 70%)
  bool isModuleCompleted(String moduleId) {
    final s = _userScores[moduleId];
    if (s == null || s is! Map) return false;
    final score = (s['score'] ?? 0) as int;
    final total = (s['total'] ?? 0) as int;
    if (total == 0) return false;
    return ((score / total) * 100).round() >= 70;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Mensajes amables y claros para cada error de Firebase Auth.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No encontramos una cuenta con ese correo. ¿Quieres crear una?';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Correo o contraseña incorrectos. Revísalos e inténtalo otra vez.';
      case 'email-already-in-use':
        return 'Ese correo ya tiene una cuenta. Prueba iniciando sesión.';
      case 'weak-password':
        return 'Tu contraseña es muy fácil de adivinar. Usa 8 caracteres con letras y números.';
      case 'invalid-email':
        return 'Ese correo no parece válido. Revísalo.';
      case 'username-taken':
        return 'Ese nombre de inventor ya está en uso. ¡Prueba con otro!';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
      case 'network-request-failed':
        return 'Parece que no hay internet. Revisa tu conexión.';
      case 'user-disabled':
        return 'Esta cuenta está desactivada. Pide ayuda a tu maestro o a tus papás.';
      case 'operation-not-allowed':
        return 'Este método de acceso no está disponible por ahora.';
      case 'requires-recent-login':
        return 'Por seguridad, vuelve a iniciar sesión para continuar.';
      default:
        return 'Algo salió mal. Inténtalo de nuevo en un momento.';
    }
  }

  /// Envía un correo para restablecer la contraseña.
  /// Devuelve `null` si todo salió bien, o un mensaje de error en español.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      // Por privacidad no revelamos si el correo existe o no.
      if (e.code == 'user-not-found') return null;
      return _mapAuthError(e.code);
    } catch (_) {
      return 'No pudimos enviar el correo. Inténtalo de nuevo.';
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
