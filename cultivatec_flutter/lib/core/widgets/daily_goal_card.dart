import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';

/// Tarjeta de inicio: aro de meta diaria, racha, semana y mensaje de Wokov.
class DailyGoalCard extends StatelessWidget {
  /// Racha oficial de días consecutivos (viene de Firestore).
  final int streak;
  final VoidCallback? onStartLesson;

  const DailyGoalCard({super.key, required this.streak, this.onStartLesson});

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    DailyGoalService.refresh();
    return ListenableBuilder(
      listenable: Listenable.merge([DailyGoalService.todayXp, DailyGoalService.goalXp, DailyGoalService.activeDays]),
      builder: (context, _) {
        final today = DailyGoalService.todayXp.value;
        final goal = DailyGoalService.goalXp.value;
        final reached = today >= goal;
        final week = DailyGoalService.weekActivity();
        final activeToday = week[DailyGoalService.todayIndex];
        final atRisk = streak > 0 && !activeToday;

        late final WokovPose pose;
        late final String message;
        if (reached) {
          pose = WokovPose.victory;
          message = '¡Meta cumplida! Wokov está muy orgulloso de ti.';
        } else if (atRisk) {
          pose = WokovPose.worried;
          message = '¡Tu racha de $streak ${streak == 1 ? 'día está' : 'días está'} en juego! Tu brote necesita agua… y tú una lección.';
        } else if (today > 0) {
          pose = WokovPose.pointUp;
          message = '¡Ya casi! Te faltan ${goal - today} XP para tu meta.';
        } else {
          pose = WokovPose.wave;
          message = streak == 0
              ? 'Una lección rápida y empiezas tu racha. ¡Vamos!'
              : '¡Buenos días, inventor! Hoy toca ganar $goal XP.';
        }

        return GestureDetector(
          onTap: onStartLesson,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(radius: 24, border: reached ? AppTheme.primaryBlue : AppTheme.borderColor),
            child: Column(
              children: [
                Row(
                  children: [
                    _GoalRing(progress: DailyGoalService.progress, today: today, goal: goal, reached: reached),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meta diaria',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            reached ? '¡Completada! 🎯' : '$today / $goal XP hoy',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: reached ? AppTheme.primaryBlue : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _StreakChip(streak: streak, active: activeToday || reached),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final on = week[i];
                    final isToday = i == DailyGoalService.todayIndex;
                    return Column(
                      children: [
                        Text(_days[i],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isToday ? AppTheme.primaryBlue : AppTheme.textMuted)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: on ? AppTheme.primaryBlue : AppTheme.bgPrimary,
                            border: Border.all(
                              color: on || isToday ? AppTheme.primaryBlue : AppTheme.borderColor,
                              width: 2.5,
                            ),
                          ),
                          child: on ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        height: 58,
                        child: WokovMascot(pose: pose, size: 54, floating: false, tappable: false),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(message,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalRing extends StatelessWidget {
  final double progress;
  final int today;
  final int goal;
  final bool reached;
  const _GoalRing({required this.progress, required this.today, required this.goal, required this.reached});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(value, reached),
          child: Center(
            child: reached
                ? const Icon(Icons.check_rounded, color: AppTheme.primaryBlue, size: 38)
                    .animate(key: const ValueKey('goal_done'))
                    .scale(begin: const Offset(0.4, 0.4), curve: Curves.easeOutBack, duration: 400.ms)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$today',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, height: 1)),
                      const Text('XP',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool reached;
  _RingPainter(this.progress, this.reached);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 11.0;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.borderColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, base);
    if (progress > 0) {
      final fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = reached ? AppTheme.primaryBlue : AppTheme.primaryLight;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.reached != reached;
}

class _StreakChip extends StatelessWidget {
  final int streak;
  final bool active;
  const _StreakChip({required this.streak, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accentOrange : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFF4E0) : AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? AppTheme.accentOrange : AppTheme.borderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          (active
              ? Icon(Icons.local_fire_department_rounded, color: color, size: 20)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.22, 1.22), duration: 520.ms, curve: Curves.easeInOut)
                  .rotate(begin: -0.02, end: 0.02, duration: 520.ms)
              : Icon(Icons.local_fire_department_rounded, color: color, size: 20)),
          const SizedBox(width: 4),
          Text(
            streak == 1 ? '1 día de racha' : '$streak días de racha',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
