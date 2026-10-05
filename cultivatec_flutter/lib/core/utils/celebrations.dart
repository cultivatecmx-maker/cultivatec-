import 'dart:collection';

enum CelebrationKind { levelUp, achievement, dailyGoal }

class Celebration {
  final CelebrationKind kind;
  final String title;
  final String subtitle;
  final int? number; // nivel alcanzado, por ejemplo

  const Celebration({required this.kind, required this.title, required this.subtitle, this.number});
}

/// Cola global de celebraciones. Cualquier parte de la app (por ejemplo el
/// `AuthProvider`) agrega elementos y el `CelebrationHost` los muestra cuando
/// la pantalla de inicio está visible.
class CelebrationService {
  static final Queue<Celebration> _queue = Queue<Celebration>();

  static bool get hasPending => _queue.isNotEmpty;

  static void push(Celebration c) => _queue.add(c);

  static Celebration? pop() => _queue.isEmpty ? null : _queue.removeFirst();

  static void clear() => _queue.clear();
}
