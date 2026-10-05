import 'package:flutter/material.dart';

/// A background tinted to a STEM area's color with a faint tiled icon motif
/// (e.g. bolts for electronics, code for programming) so each course feels
/// themed — not just generic scenery.
class ThemedBackground extends StatelessWidget {
  final Widget child;
  final Color color;
  final IconData icon;

  const ThemedBackground({super.key, required this.child, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(color, Colors.white, 0.82)!;
    final tile = Color.lerp(color, Colors.white, 0.60)!;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: base)),
        // Soft glow at the top.
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0)]),
            ),
          ),
        ),
        // Faint tiled icon motif, painted (no layout overflow).
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: CustomPaint(painter: _MotifPainter(icon, tile)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _MotifPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  const _MotifPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 78.0;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (double y = -cell; y < size.height + cell; y += cell) {
      final row = (y / cell).floor();
      final stagger = row.isEven ? 0.0 : cell / 2;
      for (double x = -cell; x < size.width + cell; x += cell) {
        tp.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontSize: 30,
            color: color,
          ),
        );
        tp.layout();
        final cx = x + stagger + cell / 2;
        final cy = y + cell / 2;
        final angle = (((row + (x / cell).floor()) % 3) - 1) * 0.18;
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(angle);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MotifPainter old) => old.icon != icon || old.color != color;
}
