import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Efectos de sonido + vibración (háptica) de la app.
///
/// Los sonidos viven en `assets/sounds/`. Si el audio falla en alguna
/// plataforma, la app sigue funcionando en silencio (nunca lanza errores).
class SoundService {
  static bool _enabled = true;
  static double _volume = 0.5;

  static bool get isEnabled => _enabled;
  static double get volume => _volume;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('cultivatec_soundEnabled') ?? true;
    _volume = prefs.getDouble('cultivatec_soundVolume') ?? 0.5;
  }

  static Future<void> setEnabled(bool val) async {
    _enabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cultivatec_soundEnabled', val);
  }

  static Future<void> setVolume(double val) async {
    _volume = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cultivatec_soundVolume', val);
  }

  static Future<void> _play(String file) async {
    if (!_enabled) return;
    try {
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(AssetSource('sounds/$file.wav'), volume: _volume);
    } catch (_) {
      // Sin audio disponible: seguimos en silencio.
    }
  }

  static void _haptic(Future<void> Function() fn) {
    if (!_enabled) return;
    try {
      fn();
    } catch (_) {}
  }

  // --- Vibración -----------------------------------------------------------
  static void hapticLight() => _haptic(HapticFeedback.lightImpact);
  static void hapticMedium() => _haptic(HapticFeedback.mediumImpact);
  static void hapticHeavy() => _haptic(HapticFeedback.heavyImpact);
  static void hapticSelect() => _haptic(HapticFeedback.selectionClick);

  // --- Interfaz ------------------------------------------------------------
  static void playClick() {
    hapticSelect();
    _play('click');
  }

  static void playTab() => playClick();
  static void playNavigate() => playClick();
  static void playBack() => playClick();
  static void playSelect() => playClick();
  static void playSave() => _play('pop');

  // --- Respuestas ----------------------------------------------------------
  static void playCorrect() {
    hapticMedium();
    _play('correct');
  }

  static void playWrong() {
    hapticHeavy();
    _play('wrong');
  }

  static void playError() => playWrong();

  // --- Recompensas ---------------------------------------------------------
  static void playXP() {
    hapticLight();
    _play('xp');
  }

  static void playLevelUp() {
    hapticHeavy();
    _play('levelup');
  }

  static void playVictory() {
    hapticHeavy();
    _play('victory');
  }

  static void playAchievement() => playLevelUp();
  static void playSkinUnlock() => playLevelUp();
  static void playStreak() => playXP();

  // --- Cuenta y social -----------------------------------------------------
  static void playLogin() => _play('pop');
  static void playLogout() => _play('pop');
  static void playFriendAccept() => _play('xp');
  static void playNotification() => _play('pop');
  static void playWorldEnter() => _play('pop');
}
