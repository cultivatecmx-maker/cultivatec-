import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';

/// Cinemática directa de un brazo de 2 segmentos.
///
/// El alumno mueve el ángulo del hombro (θ1) y del codo (θ2) y ve, en tiempo
/// real, dónde queda la mano:
///   x = L1·cos(θ1) + L2·cos(θ1 + θ2)
///   y = L1·sin(θ1) + L2·sin(θ1 + θ2)
/// El círculo punteado es el "espacio de trabajo": nunca se puede llegar más
/// lejos que L1 + L2. Además hay un reto: llevar la mano al punto verde.
class ArmKinematicsSimulatorScreen extends StatefulWidget {
  const ArmKinematicsSimulatorScreen({super.key});

  @override
  State<ArmKinematicsSimulatorScreen> createState() => _ArmKinematicsSimulatorScreenState();
}

class _ArmKinematicsSimulatorScreenState extends State<ArmKinematicsSimulatorScreen> {
  double _t1 = 60; // hombro, grados
  double _t2 = -40; // codo, grados (relativo al primer segmento)
  double _l1 = 90; // longitud del segmento 1
  double _l2 = 70; // longitud del segmento 2

  final _rng = math.Random();
  late Offset _target;
  int _hits = 0;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    _target = _randomTarget();
  }

  static double _rad(double deg) => deg * math.pi / 180;

  Offset get _elbow => Offset(_l1 * math.cos(_rad(_t1)), _l1 * math.sin(_rad(_t1)));

  Offset get _hand => Offset(
        _l1 * math.cos(_rad(_t1)) + _l2 * math.cos(_rad(_t1 + _t2)),
        _l1 * math.sin(_rad(_t1)) + _l2 * math.sin(_rad(_t1 + _t2)),
      );

  /// Punto siempre alcanzable con los ángulos permitidos.
  Offset _randomTarget() {
    final a = 20 + _rng.nextDouble() * 140; // 20°–160°
    final b = -100 + _rng.nextDouble() * 200; // -100°–100°
    return Offset(
      _l1 * math.cos(_rad(a)) + _l2 * math.cos(_rad(a + b)),
      _l1 * math.sin(_rad(a)) + _l2 * math.sin(_rad(a + b)),
    );
  }

  void _checkTarget() {
    if (_celebrating) return;
    if ((_hand - _target).distance < 9) {
      setState(() {
        _celebrating = true;
        _hits++;
      });
      SoundService.playCorrect();
      BlueConfetti.show(context, count: 60, origin: const Offset(0.5, 0.3));
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() {
          _target = _randomTarget();
          _celebrating = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hand = _hand;
    final reach = hand.distance;
    final maxReach = _l1 + _l2;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cinemática de un brazo'),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reto
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                  decoration: AppTheme.cardDecoration(radius: 20, border: AppTheme.primaryLight),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        height: 58,
                        child: WokovMascot(
                          pose: _celebrating ? WokovPose.victory : WokovPose.pointSide,
                          size: 54,
                          floating: false,
                          tappable: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _celebrating ? '¡Lo lograste! Va otro objetivo…' : 'Reto: lleva la mano (punto dorado) al objetivo verde.',
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.accentGreen, borderRadius: BorderRadius.circular(14)),
                        child: Text('$_hits',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CustomPaint(
                        painter: _ArmPainter(
                          l1: _l1,
                          l2: _l2,
                          t1: _t1,
                          elbow: _elbow,
                          hand: hand,
                          target: _target,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _readout('X', hand.dx.toStringAsFixed(1), AppTheme.primaryBlue),
                    const SizedBox(width: 10),
                    _readout('Y', hand.dy.toStringAsFixed(1), AppTheme.toneIndigo),
                    const SizedBox(width: 10),
                    _readout('Alcance', '${reach.toStringAsFixed(0)}/${maxReach.toStringAsFixed(0)}', AppTheme.toneAzure),
                  ],
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sliderBlock('Hombro  θ1', _t1, 0, 180, '°', AppTheme.primaryBlue, (v) {
                        setState(() => _t1 = v);
                        _checkTarget();
                      }),
                      const SizedBox(height: 14),
                      _sliderBlock('Codo  θ2', _t2, -150, 150, '°', AppTheme.toneIndigo, (v) {
                        setState(() => _t2 = v);
                        _checkTarget();
                      }),
                      const SizedBox(height: 14),
                      _sliderBlock('Largo del segmento 1', _l1, 40, 120, '', AppTheme.toneAzure, (v) {
                        setState(() => _l1 = v);
                      }, onEnd: () => setState(() => _target = _randomTarget())),
                      const SizedBox(height: 14),
                      _sliderBlock('Largo del segmento 2', _l2, 40, 120, '', AppTheme.toneSky, (v) {
                        setState(() => _l2 = v);
                      }, onEnd: () => setState(() => _target = _randomTarget())),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¿Qué está pasando?',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary)),
                      SizedBox(height: 8),
                      Text(
                        'La posición de la mano se calcula sumando dos vectores, uno por segmento:\n\n'
                        'x = L1·cos(θ1) + L2·cos(θ1 + θ2)\n'
                        'y = L1·sin(θ1) + L2·sin(θ1 + θ2)\n\n'
                        'El segundo segmento usa el ángulo acumulado (θ1 + θ2). El círculo punteado es el '
                        '"espacio de trabajo": la mano nunca llega más lejos que L1 + L2, sin importar los ángulos.',
                        style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readout(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: AppTheme.cardDecoration(radius: 18),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderBlock(String label, double value, double min, double max, String unit, Color color,
      ValueChanged<double> onChanged,
      {VoidCallback? onEnd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Text('${value.round()}$unit',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: AppTheme.borderColor,
            overlayColor: color.withValues(alpha: 0.15),
            trackHeight: 8,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
            onChangeEnd: onEnd == null ? null : (_) => onEnd(),
          ),
        ),
      ],
    );
  }
}

class _ArmPainter extends CustomPainter {
  final double l1;
  final double l2;
  final double t1;
  final Offset elbow;
  final Offset hand;
  final Offset target;

  const _ArmPainter({
    required this.l1,
    required this.l2,
    required this.t1,
    required this.elbow,
    required this.hand,
    required this.target,
  });

  static const double _span = 240; // alcance máximo posible (120 + 120)

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final k = (s * 0.46) / _span;
    Offset p(Offset u) => Offset(c.dx + u.dx * k, c.dy - u.dy * k); // y hacia arriba

    // Fondo
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF1F7FF));

    // Cuadrícula
    final grid = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;
    for (var u = -_span; u <= _span; u += 40) {
      canvas.drawLine(p(Offset(u, -_span)), p(Offset(u, _span)), grid);
      canvas.drawLine(p(Offset(-_span, u)), p(Offset(_span, u)), grid);
    }
    final axis = Paint()
      ..color = AppTheme.primaryLight
      ..strokeWidth = 2;
    canvas.drawLine(p(const Offset(-_span, 0)), p(const Offset(_span, 0)), axis);
    canvas.drawLine(p(const Offset(0, -_span)), p(const Offset(0, _span)), axis);

    // Espacio de trabajo
    final r = (l1 + l2) * k;
    canvas.drawCircle(c, r, Paint()..color = AppTheme.primaryBlue.withValues(alpha: 0.08));
    final dash = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final circle = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    for (final m in circle.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 9, m.length)), dash);
        d += 17;
      }
    }

    // Ángulo del hombro
    final arcPaint = Paint()
      ..color = AppTheme.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: c, radius: 30), 0, -t1 * math.pi / 180, false, arcPaint);

    // Objetivo
    final tp = p(target);
    canvas.drawCircle(tp, 17, Paint()..color = AppTheme.accentGreen.withValues(alpha: 0.25));
    canvas.drawCircle(tp, 9, Paint()..color = AppTheme.accentGreen);
    canvas.drawCircle(tp, 3.5, Paint()..color = Colors.white);

    // Base
    final base = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, 16), width: 62, height: 24), const Radius.circular(8));
    canvas.drawRRect(base, Paint()..color = AppTheme.navy);

    // Segmentos
    final b = c, e = p(elbow), h = p(hand);
    void seg(Offset a, Offset z) {
      canvas.drawLine(
          a,
          z,
          Paint()
            ..color = AppTheme.navy
            ..strokeWidth = 17
            ..strokeCap = StrokeCap.round);
      canvas.drawLine(
          a,
          z,
          Paint()
            ..color = AppTheme.primaryBlue
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round);
    }

    seg(b, e);
    seg(e, h);

    // Articulaciones
    for (final j in [b, e]) {
      canvas.drawCircle(j, 12, Paint()..color = AppTheme.navy);
      canvas.drawCircle(j, 7.5, Paint()..color = Colors.white);
    }

    // Mano
    canvas.drawCircle(h, 13, Paint()..color = Colors.white);
    canvas.drawCircle(h, 10, Paint()..color = AppTheme.accentGold);

    // Coordenadas de la mano
    final tpnt = TextPainter(
      text: TextSpan(
        text: '(${hand.dx.toStringAsFixed(0)}, ${hand.dy.toStringAsFixed(0)})',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.navy),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var lx = h.dx + 16;
    var ly = h.dy - 26;
    lx = lx.clamp(4.0, size.width - tpnt.width - 4);
    ly = ly.clamp(4.0, size.height - tpnt.height - 4);
    final label = RRect.fromRectAndRadius(
        Rect.fromLTWH(lx - 6, ly - 3, tpnt.width + 12, tpnt.height + 6), const Radius.circular(8));
    canvas.drawRRect(label, Paint()..color = Colors.white.withValues(alpha: 0.92));
    tpnt.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(covariant _ArmPainter old) => true;
}
