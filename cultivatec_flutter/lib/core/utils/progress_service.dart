import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Meta diaria de XP y días activos (para el aro de meta y la semana de racha).
///
/// Se guarda en el dispositivo (SharedPreferences). La racha "oficial" de días
/// consecutivos sigue viviendo en Firestore (`currentStreak`).
class DailyGoalService {
  static const goalOptions = <int>[20, 30, 50, 100];

  static final ValueNotifier<int> goalXp = ValueNotifier<int>(30);
  static final ValueNotifier<int> todayXp = ValueNotifier<int>(0);
  static final ValueNotifier<Set<String>> activeDays = ValueNotifier<Set<String>>(<String>{});

  static SharedPreferences? _prefs;
  static String _loadedDay = '';

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String get _today => dayKey(DateTime.now());

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    goalXp.value = _prefs!.getInt('cultivatec_dailyGoalXp') ?? 30;
    activeDays.value = (_prefs!.getStringList('cultivatec_activeDays') ?? <String>[]).toSet();
    _refreshToday();
  }

  /// Si cambió el día (la app estuvo abierta de madrugada), reinicia el contador.
  static void _refreshToday() {
    final t = _today;
    if (_loadedDay != t) {
      _loadedDay = t;
      todayXp.value = _prefs?.getInt('cultivatec_dailyXp_$t') ?? 0;
    }
  }

  static void refresh() => _refreshToday();

  static bool get goalReachedToday => todayXp.value >= goalXp.value;
  static double get progress => (todayXp.value / goalXp.value).clamp(0.0, 1.0);

  /// Suma XP al día de hoy. Devuelve `true` si con esto se CUMPLIÓ la meta.
  static bool addXp(int xp) {
    if (xp <= 0) return false;
    _refreshToday();
    final before = todayXp.value;
    final after = before + xp;
    todayXp.value = after;

    final days = Set<String>.from(activeDays.value)..add(_today);
    // Guardamos solo los últimos 60 días.
    final sorted = days.toList()..sort();
    final trimmed = sorted.length > 60 ? sorted.sublist(sorted.length - 60) : sorted;
    activeDays.value = trimmed.toSet();

    _prefs?.setInt('cultivatec_dailyXp_$_today', after);
    _prefs?.setStringList('cultivatec_activeDays', trimmed);

    return before < goalXp.value && after >= goalXp.value;
  }

  static Future<void> setGoal(int xp) async {
    goalXp.value = xp;
    await _prefs?.setInt('cultivatec_dailyGoalXp', xp);
  }

  /// Lunes → domingo de la semana actual: `true` si hubo actividad ese día.
  static List<bool> weekActivity() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => activeDays.value.contains(dayKey(monday.add(Duration(days: i)))));
  }

  /// Índice (0 = lunes) de hoy.
  static int get todayIndex => DateTime.now().weekday - 1;
}

/// Preferencia de "reducir movimiento": apaga confeti, temblores y flotación.
/// También respeta el ajuste de accesibilidad del sistema.
class MotionSettings {
  static final ValueNotifier<bool> reduce = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    reduce.value = prefs.getBool('cultivatec_reduceMotion') ?? false;
  }

  static Future<void> setReduce(bool v) async {
    reduce.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cultivatec_reduceMotion', v);
  }

  /// `true` si hay que evitar animaciones llamativas en este contexto.
  static bool shouldReduce(BuildContext? context) {
    if (reduce.value) return true;
    if (context == null) return false;
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}
