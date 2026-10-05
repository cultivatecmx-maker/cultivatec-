import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';

/// Shows a diode turning an AC input into a half-wave rectified output.
///
/// The input waveform is fixed; the output waveform is derived from it by
/// zeroing out whichever half-cycle the diode blocks. A small marker travels
/// across both graphs in sync so learners can see, moment to moment, when
/// the diode is conducting versus blocking.
class DiodeRectifierSimulatorScreen extends StatefulWidget {
  const DiodeRectifierSimulatorScreen({super.key});

  @override
  State<DiodeRectifierSimulatorScreen> createState() => _DiodeRectifierSimulatorScreenState();
}

class _DiodeRectifierSimulatorScreenState extends State<DiodeRectifierSimulatorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _inverted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _inputAt(double x) => math.sin(4 * math.pi * x);

  double _outputAt(double x) {
    final raw = _inputAt(x);
    if (_inverted) {
      return raw < 0 ? raw : 0;
    }
    return raw > 0 ? raw : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Diodo Rectificador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entrada (corriente alterna)',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _WavePainter(
                            valueAt: _inputAt,
                            phase: _controller.value,
                            lineColor: AppTheme.accentCyan,
                            markerActiveAt: (x) => true,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Salida (rectificada)',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      Row(
                        children: [
                          const Text('Diodo invertido',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Switch(
                            value: _inverted,
                            onChanged: (v) => setState(() => _inverted = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _WavePainter(
                            valueAt: _outputAt,
                            phase: _controller.value,
                            lineColor: AppTheme.accentGreen,
                            markerActiveAt: (x) => _outputAt(x).abs() > 0.02,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Qué está pasando?',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                  SizedBox(height: 8),
                  Text(
                    'Un diodo solo deja pasar corriente en una dirección. Cuando la '
                    'corriente alterna sube de un lado, el diodo conduce y ves el pulso '
                    'en la salida; cuando baja del otro lado, el diodo bloquea y la '
                    'salida se queda en cero. Por eso la salida "rectificada" solo tiene '
                    'mitades del pulso original, nunca el ciclo completo. Invierte el '
                    'diodo para ver que entonces deja pasar la mitad contraria.',
                    style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double Function(double x) valueAt;
  final double phase;
  final Color lineColor;
  final bool Function(double x) markerActiveAt;

  _WavePainter({
    required this.valueAt,
    required this.phase,
    required this.lineColor,
    required this.markerActiveAt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final amplitude = size.height / 2 - 12;

    final axisPaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axisPaint);

    final wavePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final x = i / steps;
      final y = midY - valueAt(x) * amplitude;
      final px = x * size.width;
      if (i == 0) {
        path.moveTo(px, y);
      } else {
        path.lineTo(px, y);
      }
    }
    canvas.drawPath(path, wavePaint);

    final markerX = phase * size.width;
    final markerValue = valueAt(phase);
    final markerY = midY - markerValue * amplitude;
    final active = markerActiveAt(phase);
    final markerPaint = Paint()..color = active ? lineColor : AppTheme.textMuted;
    canvas.drawCircle(Offset(markerX, markerY), active ? 7 : 5, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
