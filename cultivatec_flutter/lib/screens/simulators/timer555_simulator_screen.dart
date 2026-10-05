import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';

/// A simplified 555 timer in astable mode: it blinks an LED on and off
/// forever, and the resistor/capacitor values the learner picks control how
/// fast it blinks — the same idea behind real 555 blinker circuits.
class Timer555SimulatorScreen extends StatefulWidget {
  const Timer555SimulatorScreen({super.key});

  @override
  State<Timer555SimulatorScreen> createState() => _Timer555SimulatorScreenState();
}

class _Timer555SimulatorScreenState extends State<Timer555SimulatorScreen> with SingleTickerProviderStateMixin {
  double _resistanceKOhm = 47; // kΩ
  double _capacitanceUf = 10; // µF
  late AnimationController _controller;

  // T ≈ 1.4 * R * C (simplified astable approximation, R in ohms, C in farads)
  double get _periodSeconds => 1.4 * (_resistanceKOhm * 1000) * (_capacitanceUf / 1e6);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _durationFromPeriod())..repeat();
  }

  Duration _durationFromPeriod() {
    final ms = (_periodSeconds * 1000).clamp(150, 8000).round();
    return Duration(milliseconds: ms);
  }

  void _updateSpeed() {
    final wasAnimating = _controller.isAnimating;
    _controller.duration = _durationFromPeriod();
    if (wasAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Temporizador 555'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final on = _controller.value < 0.5;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? AppTheme.accentOrange : AppTheme.bgSecondary,
                          boxShadow: on
                              ? [BoxShadow(color: AppTheme.accentOrange.withValues(alpha: 0.6), blurRadius: 24, spreadRadius: 6)]
                              : [],
                        ),
                        child: Icon(Icons.lightbulb_rounded, size: 38, color: on ? Colors.white : AppTheme.textMuted),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('${_periodSeconds.toStringAsFixed(2)} s por ciclo',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, fontSize: 18)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => CustomPaint(
                        painter: _TrianglePainter(phase: _controller.value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sliderBlock(
                    label: 'Resistencia (R)',
                    value: _resistanceKOhm,
                    min: 1,
                    max: 200,
                    unit: 'kΩ',
                    color: AppTheme.accentPurple,
                    onChanged: (v) => setState(() {
                      _resistanceKOhm = v;
                      _updateSpeed();
                    }),
                  ),
                  const SizedBox(height: 22),
                  _sliderBlock(
                    label: 'Capacitor (C)',
                    value: _capacitanceUf,
                    min: 1,
                    max: 100,
                    unit: 'µF',
                    color: AppTheme.accentCyan,
                    onChanged: (v) => setState(() {
                      _capacitanceUf = v;
                      _updateSpeed();
                    }),
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
                    'Un 555 en modo astable carga y descarga un capacitor una y otra '
                    'vez a través de una resistencia, y usa ese vaivén para prender y '
                    'apagar su salida sin parar — como un metrónomo electrónico. Entre '
                    'más grande la resistencia o el capacitor, más tarda cada ciclo de '
                    'carga/descarga, y más lento parpadea el LED.',
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

  Widget _sliderBlock({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text('${value.toStringAsFixed(0)} $unit', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final double phase;
  _TrianglePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final amp = size.height / 2 - 10;

    final axisPaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axisPaint);

    final wavePaint = Paint()
      ..color = AppTheme.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double triangleAt(double x) {
      // 2 full triangle cycles across the visible window, synced with phase.
      final t = (x * 2 + phase) % 1.0;
      return t < 0.5 ? (t * 4 - 1) : (3 - t * 4);
    }

    final path = Path();
    const steps = 100;
    for (int i = 0; i <= steps; i++) {
      final x = i / steps;
      final y = midY - triangleAt(x) * amp;
      final px = x * size.width;
      if (i == 0) {
        path.moveTo(px, y);
      } else {
        path.lineTo(px, y);
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => true;
}
