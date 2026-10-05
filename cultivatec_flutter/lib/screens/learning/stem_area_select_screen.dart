import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';

/// Selector de áreas STEM: encabezado azul con Wokov, y una tarjeta por área con
/// su progreso. La área recomendada (la que sigue) se marca con «SIGUE AQUÍ».
class StemAreaSelectScreen extends StatelessWidget {
  final void Function(String) onSelectArea; // recibe el stemAreaId

  /// Puntajes del usuario (`'<area>_<lección>'` → `{completed, stars, ...}`).
  final Map<String, dynamic> userScores;

  const StemAreaSelectScreen({super.key, required this.onSelectArea, this.userScores = const {}});

  bool _done(StemArea area, Lesson l) {
    final sc = userScores['${area.id}_${l.id}'];
    return sc is Map && sc['completed'] == true;
  }

  int _completed(StemArea area) => area.lessons.where((l) => _done(area, l)).length;

  /// Primera área con avance sin terminar; si no hay, la primera incompleta.
  int _recommended() {
    var firstIncomplete = -1;
    for (var i = 0; i < stemAreas.length; i++) {
      final done = _completed(stemAreas[i]);
      final total = stemAreas[i].lessons.length;
      if (done < total) {
        if (done > 0) return i;
        if (firstIncomplete < 0) firstIncomplete = i;
      }
    }
    return firstIncomplete;
  }

  @override
  Widget build(BuildContext context) {
    final rec = _recommended();
    final totalDone = stemAreas.fold<int>(0, (a, e) => a + _completed(e));
    final totalAll = stemAreas.fold<int>(0, (a, e) => a + e.lessons.length);

    return AnimatedBackground(
      child: Column(
        children: [
          BlueHeader(
            title: 'Tu camino STEM',
            subtitle: totalDone == 0
                ? 'Elige tu nivel: Chispa, Maker o Inventor.'
                : '$totalDone de $totalAll lecciones completadas. ¡Sigue así!',
            mascot: const WokovMascot(
              pose: WokovPose.idle,
              size: 104,
              idleAction: WokovAction.wave,
              actionInterval: Duration(seconds: 6),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              itemCount: stemAreas.length,
              itemBuilder: (context, idx) {
                final area = stemAreas[idx];
                return _AreaCard(
                  area: area,
                  done: _completed(area),
                  total: area.lessons.length,
                  recommended: idx == rec,
                  onTap: () {
                    SoundService.playClick();
                    onSelectArea(area.id);
                  },
                )
                    .animate()
                    .fadeIn(delay: (120 + idx * 90).ms, duration: 450.ms)
                    .slideY(begin: 0.18, end: 0, curve: Curves.easeOutBack);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatefulWidget {
  final StemArea area;
  final int done;
  final int total;
  final bool recommended;
  final VoidCallback onTap;

  const _AreaCard({
    required this.area,
    required this.done,
    required this.total,
    required this.recommended,
    required this.onTap,
  });

  @override
  State<_AreaCard> createState() => _AreaCardState();
}

class _AreaCardState extends State<_AreaCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final color = area.color;
    final dark = Color.lerp(color, Colors.black, 0.32)!;
    final pct = widget.total == 0 ? 0.0 : (widget.done / widget.total).clamp(0.0, 1.0);
    final finished = widget.total > 0 && widget.done >= widget.total;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        margin: EdgeInsets.only(top: _pressed ? 5 : 0, bottom: _pressed ? 18 : 23),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(color, Colors.white, 0.12)!, color],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _pressed ? const [] : [BoxShadow(color: dark, blurRadius: 0, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            // Icono gigante decorativo de fondo
            Positioned(
              right: -18,
              bottom: -26,
              child: Icon(area.icon, size: 120, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                      ),
                      child: Icon(area.icon, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.recommended || finished)
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: finished ? AppTheme.accentGreen : AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(finished ? '¡COMPLETADA!' : 'SIGUE AQUÍ',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: finished ? Colors.white : AppTheme.navy)),
                            ),
                          Text(area.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4)),
                          const SizedBox(height: 2),
                          Text(area.tagline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.88),
                                  height: 1.3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_rounded, size: 20, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progreso del área
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: pct <= 0 ? 0.03 : pct,
                          child: Container(
                            decoration: BoxDecoration(
                              color: finished ? AppTheme.accentGreen : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${widget.done}/${widget.total}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
