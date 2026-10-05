import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';

/// Confeti AZUL de Cultivatec. Sin paquetes externos.
///
/// Uso rápido (se dibuja encima de toda la pantalla y se limpia solo):
/// ```dart
/// BlueConfetti.show(context);                       // explosión grande
/// BlueConfetti.show(context, style: ConfettiStyle.rain);
/// BlueConfetti.show(context, style: ConfettiStyle.burst, count: 40,
///     origin: const Offset(0.5, 0.8));              // pequeña, desde abajo
/// ```
enum ConfettiStyle {
  /// Explota desde un punto y cae por gravedad.
  burst,

  /// Llueve desde arriba de la pantalla.
  rain,

  /// Dos cañones laterales disparan hacia el centro.
  cannons,
}

class BlueConfetti {
  static const palette = <Color>[
    Color(0xFF0958C2), // azul marca
    Color(0xFF1F6FEB), // azul principal
    Color(0xFF5AA7FF), // azul claro
    Color(0xFF8CC8FF), // celeste
    Color(0xFF1CB0F6), // cian
    Color(0xFFDCEBFF), // hielo
    Colors.white,
  ];

  static const _leaf = Color(0xFF7CC142); // guiño al brote de Wokov

  static void show(
    BuildContext context, {
    ConfettiStyle style = ConfettiStyle.burst,
    int count = 90,
    Offset origin = const Offset(0.5, 0.45),
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    if (MotionSettings.shouldReduce(context)) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: ConfettiBurst(
            style: style,
            count: count,
            origin: origin,
            duration: duration,
            onDone: () => entry.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entry);
  }
}

class ConfettiBurst extends StatefulWidget {
  final ConfettiStyle style;
  final int count;

  /// Punto de origen como fracción de la pantalla (0..1).
  final Offset origin;
  final Duration duration;
  final VoidCallback? onDone;

  const ConfettiBurst({
    super.key,
    this.style = ConfettiStyle.burst,
    this.count = 90,
    this.origin = const Offset(0.5, 0.45),
    this.duration = const Duration(milliseconds: 2600),
    this.onDone,
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _pieces = List.generate(widget.count, (i) => _Piece.random(rng, widget.style, widget.origin, i));
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone?.call();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_pieces, _c.value, widget.duration.inMilliseconds / 1000.0),
      ),
    );
  }
}

enum _Shape { rect, circle, strip, leaf }

class _Piece {
  final Color color;
  final _Shape shape;
  final double size;
  final double startX; // fracción de ancho
  final double startY; // fracción de alto
  final double vx; // px/s
  final double vy; // px/s
  final double gravity; // px/s²
  final double spin; // rad/s
  final double rot0;
  final double delay; // 0..1 de la duración
  final double wobble;

  _Piece({
    required this.color,
    required this.shape,
    required this.size,
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.gravity,
    required this.spin,
    required this.rot0,
    required this.delay,
    required this.wobble,
  });

  factory _Piece.random(Random r, ConfettiStyle style, Offset origin, int i) {
    final palette = BlueConfetti.palette;
    // ~1 de cada 14 piezas es una hojita verde.
    final leaf = r.nextInt(14) == 0;
    final color = leaf ? BlueConfetti._leaf : palette[r.nextInt(palette.length)];
    final shape = leaf
        ? _Shape.leaf
        : _Shape.values[r.nextInt(3)];
    final size = 6.0 + r.nextDouble() * 8;
    double sx = origin.dx, sy = origin.dy, vx, vy, delay = 0, g = 900;

    switch (style) {
      case ConfettiStyle.burst:
        final ang = r.nextDouble() * 2 * pi;
        final sp = 250 + r.nextDouble() * 520;
        vx = cos(ang) * sp;
        vy = sin(ang) * sp - 260;
        break;
      case ConfettiStyle.rain:
        sx = r.nextDouble();
        sy = -0.05 - r.nextDouble() * 0.15;
        vx = (r.nextDouble() - 0.5) * 90;
        vy = 120 + r.nextDouble() * 220;
        g = 120 + r.nextDouble() * 120;
        delay = r.nextDouble() * 0.45;
        break;
      case ConfettiStyle.cannons:
        final left = i.isEven;
        sx = left ? -0.02 : 1.02;
        sy = 0.78;
        final sp = 520 + r.nextDouble() * 520;
        // hacia arriba y hacia el centro
        final up = -(0.9 + r.nextDouble() * 0.6);
        vx = (left ? 1 : -1) * sp * (0.35 + r.nextDouble() * 0.4);
        vy = sp * up;
        delay = r.nextDouble() * 0.12;
        break;
    }

    return _Piece(
      color: color,
      shape: shape,
      size: size,
      startX: sx,
      startY: sy,
      vx: vx,
      vy: vy,
      gravity: g,
      spin: (r.nextDouble() - 0.5) * 14,
      rot0: r.nextDouble() * 2 * pi,
      delay: delay,
      wobble: r.nextDouble() * 2 * pi,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t; // 0..1
  final double seconds;

  _ConfettiPainter(this.pieces, this.t, this.seconds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final time = local * seconds;
      final x = p.startX * size.width + p.vx * time + sin(time * 4 + p.wobble) * 8;
      final y = p.startY * size.height + p.vy * time + 0.5 * p.gravity * time * time;
      if (y > size.height + 40 || x < -60 || x > size.width + 60) continue;
      final fade = local > 0.78 ? (1 - (local - 0.78) / 0.22) : 1.0;
      paint.color = p.color.withValues(alpha: fade.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot0 + p.spin * time);
      // efecto de giro 3D: aplastamos en un eje
      final flip = cos(time * 6 + p.wobble).abs().clamp(0.15, 1.0);
      canvas.scale(1, flip);
      switch (p.shape) {
        case _Shape.rect:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), const Radius.circular(2)),
            paint,
          );
          break;
        case _Shape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.38, paint);
          break;
        case _Shape.strip:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: p.size * 1.6, height: p.size * 0.32), const Radius.circular(2)),
            paint,
          );
          break;
        case _Shape.leaf:
          final path = Path()
            ..moveTo(0, -p.size * 0.6)
            ..quadraticBezierTo(p.size * 0.7, 0, 0, p.size * 0.6)
            ..quadraticBezierTo(-p.size * 0.7, 0, 0, -p.size * 0.6);
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
