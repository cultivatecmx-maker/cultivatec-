import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the learner's position inside the curriculum.
///
/// Navigation has two levels:
///
///  1. **STEM area** — one of the levels defined in `data/static/stem_content.dart`
///     (Chispa → Maker → Inventor). `null` means the learner has not picked one
///     yet and should see the area selector.
///  2. **Lessons** — resolved from the selected area. Progress itself lives in
///     Firestore and is exposed through `AuthProvider`, not here.
///
/// The selection is cached in `SharedPreferences` so reopening the app drops
/// the learner back where they left off.
class LearningProvider extends ChangeNotifier {
  static const _kStemAreaId = 'cultivatec_currentStemAreaId';

  String? _currentStemAreaId;

  LearningProvider() {
    _restore();
  }

  /// Id of the STEM area currently open, or `null` while on the selector.
  String? get currentStemAreaId => _currentStemAreaId;

  /// Whether the area selector should be shown instead of the lesson path.
  bool get showAreaSelector => _currentStemAreaId == null;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStemAreaId = prefs.getString(_kStemAreaId);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final id = _currentStemAreaId;
    if (id != null) {
      await prefs.setString(_kStemAreaId, id);
    } else {
      await prefs.remove(_kStemAreaId);
    }
  }

  /// Opens the lesson path for [areaId].
  void enterStemArea(String areaId) {
    _currentStemAreaId = areaId;
    _persist();
    notifyListeners();
  }

  /// Returns to the STEM area selector.
  void exitToAreaSelector() {
    _currentStemAreaId = null;
    _persist();
    notifyListeners();
  }
}
