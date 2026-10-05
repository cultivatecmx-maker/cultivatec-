import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';
import 'package:cultivatec_flutter/core/widgets/themed_background.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/screens/learning/module_list_screen.dart';
import 'package:cultivatec_flutter/screens/robot/circuit_builder_screen.dart';

class LessonPathScreen extends StatelessWidget {
  final String stemAreaId;
  final VoidCallback onBack;
  final Map<String, dynamic> userScores;
  final int friendsCount;

  const LessonPathScreen({
    super.key,
    required this.stemAreaId,
    required this.onBack,
    required this.userScores,
    required this.friendsCount,
  });

  bool _done(StemArea area, Lesson l) {
    final sc = userScores['${area.id}_${l.id}'];
    return sc is Map && sc['completed'] == true;
  }

  int _stars(StemArea area, Lesson l) {
    final sc = userScores['${area.id}_${l.id}'];
    if (sc is Map && sc['stars'] is int) return (sc['stars'] as int).clamp(0, 3);
    return 0;
  }

  /// Agrupa las lecciones en unidades según su módulo (`subtitle`) y agrega un
  /// banner al inicio y un cofre al final de cada unidad.
  List<_PathItem> _buildItems(StemArea area) {
    final items = <_PathItem>[];
    var unit = 0;
    var i = 0;
    while (i < area.lessons.length) {
      final sub = area.lessons[i].subtitle;
      var j = i;
      while (j < area.lessons.length && area.lessons[j].subtitle == sub) {
        j++;
      }
      unit++;
      final group = area.lessons.sublist(i, j);
      final doneCount = group.where((l) => _done(area, l)).length;
      items.add(_PathItem.banner(unit, sub.isEmpty ? 'Unidad $unit' : sub, doneCount, group.length));
      for (var k = i; k < j; k++) {
        items.add(_PathItem.lesson(k, isLastInUnit: k == j - 1));
      }
      items.add(_PathItem.chest(unit, doneCount == group.length));
      i = j;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final area = areaById(stemAreaId);
    final items = _buildItems(area);
    final completed = area.lessons.where((l) => _done(area, l)).length;

    return Scaffold(
      body: ThemedBackground(
        color: area.color,
        icon: area.icon,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, area, completed, area.lessons.length),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 140),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    Widget w;
                    switch (it.type) {
                      case _PathItemType.banner:
                        w = _UnitBanner(
                          unit: it.unit,
                          title: it.title,
                          done: it.done,
                          total: it.total,
                          color: area.color,
                        );
                        break;
                      case _PathItemType.chest:
                        w = _ChestTile(areaId: area.id, unit: it.unit, unlocked: it.chestUnlocked, color: area.color);
                        break;
                      case _PathItemType.lesson:
                        w = _lessonNode(context, area, it);
                        break;
                    }
                    return w
                        .animate()
                        .fadeIn(delay: (60 * math.min(i, 8)).ms, duration: 350.ms)
                        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lessonNode(BuildContext context, StemArea area, _PathItem it) {
    final idx = it.index;
    final lesson = area.lessons[idx];
    final isFirst = idx == 0;
    final previousCompleted = !isFirst && _done(area, area.lessons[idx - 1]);
    final unlocked = isFirst || previousCompleted;
    final currentCompleted = _done(area, lesson);

    return _PathNode(
      lesson: lesson,
      area: area,
      index: idx,
      unlocked: unlocked,
      isCompleted: currentCompleted,
      isNextUnlocked: currentCompleted,
      isLast: it.isLastInUnit,
      stars: currentCompleted ? _stars(area, lesson) : 0,
      onTap: unlocked
          ? () {
              SoundService.playClick();
              Navigator.of(context).push(
                AppTheme.smoothRoute(LessonScreen(
                  stemAreaId: area.id,
                  moduleId: lesson.id,
                )),
              );
            }
          : () {
              SoundService.playWrong();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    content: const Text(
                      '🔒 Completa la lección anterior para desbloquear esta.',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    backgroundColor: AppTheme.brandBlue,
                  ),
                );
            },
    );
  }

  Widget _buildHeader(BuildContext context, StemArea area, int completed, int total) {
    final pct = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderColor, width: 2),
                boxShadow: AppTheme.shadowSm,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 10,
                          color: AppTheme.borderColor,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: pct.clamp(0.0, 1.0),
                            child: Container(color: area.color),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$completed/$total',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          if (area.id == 'electronica') ...[
            const SizedBox(width: 12),
            // Acceso rápido a la práctica de electrónica (Simulador)
            GestureDetector(
              onTap: () => Navigator.of(context).push(AppTheme.smoothRoute(const CircuitBuilderScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: AppTheme.primaryDark, offset: Offset(0, 4), blurRadius: 0)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.memory_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Práctica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _PathItemType { banner, lesson, chest }

class _PathItem {
  final _PathItemType type;
  final int index; // lección
  final bool isLastInUnit;
  final int unit;
  final String title;
  final int done;
  final int total;
  final bool chestUnlocked;

  const _PathItem._(this.type,
      {this.index = 0,
      this.isLastInUnit = false,
      this.unit = 0,
      this.title = '',
      this.done = 0,
      this.total = 0,
      this.chestUnlocked = false});

  factory _PathItem.banner(int unit, String title, int done, int total) =>
      _PathItem._(_PathItemType.banner, unit: unit, title: title, done: done, total: total);

  factory _PathItem.lesson(int index, {required bool isLastInUnit}) =>
      _PathItem._(_PathItemType.lesson, index: index, isLastInUnit: isLastInUnit);

  factory _PathItem.chest(int unit, bool unlocked) =>
      _PathItem._(_PathItemType.chest, unit: unit, chestUnlocked: unlocked);
}

/// Banner al inicio de cada unidad.
class _UnitBanner extends StatelessWidget {
  final int unit;
  final String title;
  final int done;
  final int total;
  final Color color;
  const _UnitBanner({required this.unit, required this.title, required this.done, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(color, Colors.black, 0.28)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 28, 20, 36),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: dark, offset: const Offset(0, 5), blurRadius: 0)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UNIDAD $unit',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 2),
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.15)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(14)),
            child: Text('$done/$total',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Cofre de recompensa al terminar una unidad (una sola vez por unidad).
class _ChestTile extends StatefulWidget {
  final String areaId;
  final int unit;
  final bool unlocked;
  final Color color;
  const _ChestTile({required this.areaId, required this.unit, required this.unlocked, required this.color});

  @override
  State<_ChestTile> createState() => _ChestTileState();
}

class _ChestTileState extends State<_ChestTile> {
  static const int _rewardXp = 20;
  bool _claimed = false;
  bool _loaded = false;

  String get _key => 'cultivatec_chest_${widget.areaId}_${widget.unit}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) {
        setState(() {
          _claimed = p.getBool(_key) ?? false;
          _loaded = true;
        });
      }
    });
  }

  Future<void> _tap() async {
    if (!_loaded) return;
    if (!widget.unlocked) {
      SoundService.playWrong();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppTheme.brandBlue,
          content: const Text('🔒 Completa todas las lecciones de la unidad para abrir el cofre.',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ));
      return;
    }
    if (_claimed) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    if (!mounted) return;
    setState(() => _claimed = true);
    SoundService.playLevelUp();
    BlueConfetti.show(context, style: ConfettiStyle.cannons, count: 110);
    context.read<AuthProvider>().syncStats({'addPoints': _rewardXp});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.primaryBlue,
        content: const Text('🎁 ¡Cofre abierto! +20 XP', style: TextStyle(fontWeight: FontWeight.w900)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.unlocked && !_claimed;
    final face = !widget.unlocked ? const Color(0xFFD5E2F5) : (_claimed ? AppTheme.primaryLight : AppTheme.accentGold);
    final depth = !widget.unlocked
        ? const Color(0xFFBCCDE6)
        : (_claimed ? AppTheme.primaryBlue : const Color(0xFFD9A400));
    final icon = !widget.unlocked ? Icons.lock_rounded : (_claimed ? Icons.check_rounded : Icons.card_giftcard_rounded);

    Widget node = _PressableNode(
      onTap: _tap,
      face: face,
      depth: depth,
      child: Icon(icon, size: 34, color: widget.unlocked ? Colors.white : AppTheme.textMuted),
    );
    if (ready) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.94, 0.94), end: const Offset(1.06, 1.06), duration: 700.ms, curve: Curves.easeInOut);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      child: Column(
        children: [
          node,
          const SizedBox(height: 6),
          Text(
            _claimed ? 'Cofre abierto' : (ready ? '¡Abre tu cofre!' : 'Cofre de unidad'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ready ? const Color(0xFFB45309) : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  final Lesson lesson;
  final StemArea area;
  final int index;
  final bool unlocked;
  final bool isCompleted;
  final bool isNextUnlocked;
  final bool isLast;
  final int stars;
  final VoidCallback? onTap;

  const _PathNode({
    required this.lesson,
    required this.area,
    required this.index,
    required this.unlocked,
    required this.isCompleted,
    required this.isNextUnlocked,
    required this.isLast,
    this.stars = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Zig-zag
    const double maxOffset = 100.0;
    final double dx = math.sin(index * 1.0) * maxOffset;
    final bool isActive = unlocked && !isCompleted;

    final Color face = unlocked ? area.color : const Color(0xFFD5E2F5);
    final Color depth = unlocked ? Color.lerp(area.color, Colors.black, 0.28)! : const Color(0xFFBCCDE6);

    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Línea que conecta con el siguiente nodo
          if (!isLast)
            Positioned(
              top: 75,
              bottom: -75,
              child: CustomPaint(
                size: const Size(300, 150),
                painter: _PathPainter(
                  startX: dx,
                  endX: math.sin((index + 1) * 1.0) * maxOffset,
                  color: isNextUnlocked ? area.color : AppTheme.borderColor,
                  isUnlocked: isNextUnlocked,
                ),
              ),
            ),

          Transform.translate(
            offset: Offset(dx, 0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Aro pulsante de la lección actual
                if (isActive)
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: area.color.withValues(alpha: 0.45), width: 5),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 900.ms, curve: Curves.easeInOut),

                // Botón 3D del nodo
                _PressableNode(
                  onTap: onTap,
                  face: face,
                  depth: depth,
                  child: Text(
                    lesson.emoji,
                    style: TextStyle(fontSize: 34, color: unlocked ? null : AppTheme.textMuted.withValues(alpha: 0.5)),
                  ),
                ),

                // Globo "¡EMPIEZA!" sobre la lección actual
                if (isActive)
                  Positioned(
                    top: -46,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: AppTheme.cardDecoration(border: area.color, radius: 14),
                      child: Text(
                        index == 0 ? '¡EMPIEZA!' : '¡SIGUE!',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: area.color, letterSpacing: 0.6),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -5, duration: 800.ms, curve: Curves.easeInOut),
                  ),

                // Wokov junto a la lección actual, señalándola
                if (isActive)
                  Positioned(
                    left: dx > 0 ? -112 : null,
                    right: dx > 0 ? null : -112,
                    bottom: -10,
                    child: WokovMascot(pose: WokovPose.pointSide, size: 88, flipHorizontal: dx <= 0),
                  ),

                // Título
                Positioned(
                  bottom: -24,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: AppTheme.cardDecoration(
                      border: unlocked ? area.color.withValues(alpha: 0.55) : AppTheme.borderColor,
                      radius: 14,
                    ),
                    child: Text(
                      lesson.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: unlocked ? AppTheme.textPrimary : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),

                // Estrellas ganadas
                if (isCompleted)
                  Positioned(
                    top: -22,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: i < stars ? AppTheme.accentGold : AppTheme.borderColor,
                        ),
                      ),
                    ),
                  ),

                // Palomita de completado
                if (isCompleted)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    ).animate().scale(curve: Curves.easeOutBack),
                  ),

                // Candado
                if (!unlocked)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderColor, width: 2),
                      ),
                      child: const Icon(Icons.lock_rounded, color: AppTheme.textMuted, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo 3D: sombra sólida debajo y se hunde al presionar.
class _PressableNode extends StatefulWidget {
  final VoidCallback? onTap;
  final Color face;
  final Color depth;
  final Widget child;
  const _PressableNode({required this.onTap, required this.face, required this.depth, required this.child});

  @override
  State<_PressableNode> createState() => _PressableNodeState();
}

class _PressableNodeState extends State<_PressableNode> {
  bool _down = false;
  static const double _d = 8;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: 80,
        height: 80,
        margin: EdgeInsets.only(top: _down ? _d : 0, bottom: _down ? 0 : _d),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.face,
          boxShadow: _down ? const [] : [BoxShadow(color: widget.depth, offset: const Offset(0, _d), blurRadius: 0)],
        ),
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.22)),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final Color color;
  final bool isUnlocked;

  _PathPainter({
    required this.startX,
    required this.endX,
    required this.color,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2 + startX, 0)
      ..cubicTo(
        size.width / 2 + startX, size.height / 2,
        size.width / 2 + endX, size.height / 2,
        size.width / 2 + endX, size.height,
      );

    // Línea plana y gruesa; más delgada y clara si está bloqueada.
    final paint = Paint()
      ..color = isUnlocked ? color : AppTheme.borderColor
      ..strokeWidth = isUnlocked ? 12 : 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.color != color ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}
