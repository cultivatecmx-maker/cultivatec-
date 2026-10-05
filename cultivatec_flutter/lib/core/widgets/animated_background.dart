import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';

/// App-wide background with a subtle robotics circuit-board (PCB) pattern:
/// faint traces, vias and chips on a light surface, plus soft color glows.
/// Kept the name `AnimatedBackground` so existing call sites keep working.
class AnimatedBackground extends StatelessWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.pageGradient))),
        // Soft corner glows for depth.
        Positioned(top: -110, right: -90, child: _glow(AppTheme.primaryBlue, 360, 0.26)),
        Positioned(bottom: -130, left: -90, child: _glow(AppTheme.accentCyan, 360, 0.24)),
        // Circuit pattern.
        const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _CircuitPainter()))),
        child,
      ],
    );
  }

  Widget _glow(Color color, double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)]),
        ),
      );
}

class _CircuitPainter extends CustomPainter {
  const _CircuitPainter();

  @override
  void paint(Canvas cv, Size s) {
    const step = 64.0;
    final trace = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final via = Paint()..color = AppTheme.primaryBlue.withValues(alpha: 0.28);
    final chip = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final chipBorder = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    int seed(int x, int y) => (x * 73856093) ^ (y * 19349663);

    for (double x = step / 2; x < s.width; x += step) {
      for (double y = step / 2; y < s.height; y += step) {
        final r = (seed(x.toInt(), y.toInt()) & 0x7fffffff) % 6;
        final cx = x, cy = y;
        // L-shaped trace stubs in a few directions, ending in a via.
        final path = Path()..moveTo(cx, cy);
        switch (r) {
          case 0:
            path
              ..lineTo(cx + step * 0.6, cy)
              ..lineTo(cx + step * 0.6, cy + step * 0.5);
            cv.drawCircle(Offset(cx + step * 0.6, cy + step * 0.5), 2.4, via);
            break;
          case 1:
            path
              ..lineTo(cx, cy + step * 0.6)
              ..lineTo(cx + step * 0.5, cy + step * 0.6);
            cv.drawCircle(Offset(cx + step * 0.5, cy + step * 0.6), 2.4, via);
            break;
          case 2:
            path.lineTo(cx + step * 0.7, cy);
            cv.drawCircle(Offset(cx + step * 0.7, cy), 2.2, via);
            break;
          case 3:
            // a small chip with pin ticks
            final rect = Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 16);
            cv.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), chip);
            cv.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), chipBorder);
            for (int i = 0; i < 3; i++) {
              final px = cx - 7 + i * 7;
              cv.drawLine(Offset(px, cy - 8), Offset(px, cy - 12), chipBorder);
              cv.drawLine(Offset(px, cy + 8), Offset(px, cy + 12), chipBorder);
            }
            continue;
          default:
            cv.drawCircle(Offset(cx, cy), 1.8, via);
            continue;
        }
        cv.drawPath(path, trace);
        cv.drawCircle(Offset(cx, cy), 2.0, via);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
