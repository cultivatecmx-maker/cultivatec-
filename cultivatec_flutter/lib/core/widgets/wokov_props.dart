import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';

/// Chispas doradas ✦ que titilan alrededor de un widget (por ejemplo Wokov al
/// celebrar). Son «dopamina»: por eso van en dorado. Respeta «Reducir
/// movimiento» (en ese caso se muestran fijas y sin parpadear).
class WokovSparkles extends StatelessWidget {
  final Widget child;
  final double size;
  const WokovSparkles({super.key, required this.child, this.size = 200});

  static const _spots = <Offset>[
    Offset(-0.02, 0.18),
    Offset(0.92, 0.10),
    Offset(0.00, 0.62),
    Offset(0.90, 0.58),
    Offset(0.46, -0.06),
  ];

  @override
  Widget build(BuildContext context) {
    final reduce = MotionSettings.shouldReduce(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        for (var i = 0; i < _spots.length; i++)
          Positioned(
            left: _spots[i].dx * size,
            top: _spots[i].dy * size,
            child: IgnorePointer(
              child: reduce
                  ? _star(i)
                  : _star(i)
                      .animate(onPlay: (c) => c.repeat(reverse: true), delay: (i * 170).ms)
                      .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1.1, 1.1),
                          duration: 650.ms,
                          curve: Curves.easeInOut)
                      .fade(begin: 0.35, end: 1, duration: 650.ms)
                      .rotate(begin: 0, end: 0.12, duration: 650.ms),
            ),
          ),
      ],
    );
  }

  Widget _star(int i) => Icon(
        Icons.auto_awesome_rounded,
        size: 14.0 + (i % 3) * 5,
        color: i.isEven ? AppTheme.accentGold : const Color(0xFFFFE27A),
      );
}
