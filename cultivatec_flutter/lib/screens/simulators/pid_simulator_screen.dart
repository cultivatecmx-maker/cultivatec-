import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';

/// Simulación discreta de un control PID sobre una planta de **segundo orden**
/// (como un motor con inercia): `x'' = ω0²·(u − x) − 2ζω0·x'`.
///
/// Es una clase pura (sin Flutter) para poder probarla:
///  * **Solo P** → se acerca a la meta pero se queda corta (error permanente).
///  * **P + I** → la integral elimina ese error.
///  * **P muy alto** → se pasa de la meta y oscila (overshoot).
///  * **D** → amortigua las oscilaciones.
/// (La derivada se calcula sobre la medición para evitar la "patada" al cambiar la meta.)
class PidSimulation {
  static const double dt = 1 / 60;
  static const double _w0 = 3.0;
  static const double _zeta = 0.45;
  static const int historyLength = 240; // 4 s a 60 pasos por segundo

  double kp;
  double ki;
  double kd;
  double target;

  double value = 0;
  double _velocity = 0;
  double _integral = 0;
  final List<double> history = [0];

  PidSimulation({this.kp = 1.2, this.ki = 0, this.kd = 0, this.target = 1.0});

  double get error => target - value;

  void reset() {
    value = 0;
    _velocity = 0;
    _integral = 0;
    history
      ..clear()
      ..add(0);
  }

  void step() {
    final e = target - value;
    _integral = (_integral + e * dt).clamp(-3.0, 3.0); // anti-windup
    final u = kp * e + ki * _integral - kd * _velocity;
    final a = _w0 * _w0 * (u - value) - 2 * _zeta * _w0 * _velocity;
    _velocity += a * dt;
    value += _velocity * dt;
    value = value.clamp(-2.0, 3.0);
    history.add(value);
    if (history.length > historyLength) history.removeAt(0);
  }

  /// Corre [seconds] segundos y devuelve la trayectoria completa (para pruebas).
  static List<double> trajectory(double kp, double ki, double kd, {double seconds = 8, double target = 1.0}) {
    final sim = PidSimulation(kp: kp, ki: ki, kd: kd, target: target);
    final out = <double>[];
    for (var i = 0; i < (seconds / dt).round(); i++) {
      sim.step();
      out.add(sim.value);
    }
    return out;
  }
}

/// Simulador PID en vivo: el alumno sube y baja P, I y D y ve la respuesta.
class PidSimulatorScreen extends StatefulWidget {
  const PidSimulatorScreen({super.key});

  @override
  State<PidSimulatorScreen> createState() => _PidSimulatorScreenState();
}

class _PidSimulatorScreenState extends State<PidSimulatorScreen> with SingleTickerProviderStateMixin {
  final PidSimulation _sim = PidSimulation();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _acc = 0;
  bool _wasOnTarget = false;

  static const _presets = <String, List<double>>{
    'Solo P': [1.2, 0, 0],
    'P + I': [1.2, 1.5, 0],
    'Mucho P': [6, 0, 0],
    'PID': [3, 2, 1.0],
  };

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Pasos de tiempo FIJO: la simulación va igual en pantallas de 60 o 120 Hz.
  void _onTick(Duration elapsed) {
    final frame = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _acc += frame.clamp(0.0, 0.1);
    var steps = 0;
    while (_acc >= PidSimulation.dt && steps < 8) {
      _sim.step();
      _acc -= PidSimulation.dt;
      steps++;
    }
    if (steps == 0) return;
    final onTarget = _sim.error.abs() < 0.02;
    if (onTarget && !_wasOnTarget && _sim.history.length > 30) SoundService.playXP();
    _wasOnTarget = onTarget;
    setState(() {});
  }

  void _applyPreset(List<double> g) {
    SoundService.playClick();
    setState(() {
      _sim
        ..kp = g[0]
        ..ki = g[1]
        ..kd = g[2]
        ..reset();
      _wasOnTarget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final err = _sim.error;
    final onTarget = err.abs() < 0.02;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Control PID'),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomPaint(
                            painter: _PidGraphPainter(history: _sim.history, target: _sim.target),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legend(AppTheme.accentGold, 'Meta'),
                          const SizedBox(width: 18),
                          _legend(AppTheme.primaryBlue, 'Salida del sistema'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _readout('Valor', _sim.value.toStringAsFixed(2), AppTheme.primaryBlue),
                    const SizedBox(width: 10),
                    _readout('Meta', _sim.target.toStringAsFixed(1), AppTheme.accentGold),
                    const SizedBox(width: 10),
                    _readout('Error', err.toStringAsFixed(2), onTarget ? AppTheme.accentGreen : AppTheme.toneAzure),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in _presets.entries) _presetChip(e.key, e.value),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(Icons.refresh_rounded, 'Reiniciar', () {
                        SoundService.playClick();
                        setState(() {
                          _sim.reset();
                          _wasOnTarget = false;
                        });
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(Icons.flag_rounded, 'Cambiar meta', () {
                        SoundService.playClick();
                        setState(() => _sim.target = _sim.target > 0.7 ? 0.4 : 1.0);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sliderBlock('P (Proporcional)', _sim.kp, 0, 6, AppTheme.primaryBlue,
                          (v) => setState(() => _sim.kp = v)),
                      const SizedBox(height: 14),
                      _sliderBlock('I (Integral)', _sim.ki, 0, 4, AppTheme.toneAzure,
                          (v) => setState(() => _sim.ki = v)),
                      const SizedBox(height: 14),
                      _sliderBlock('D (Derivativo)', _sim.kd, 0, 2, AppTheme.toneIndigo,
                          (v) => setState(() => _sim.kd = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pruébalo tú mismo',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary)),
                      SizedBox(height: 8),
                      Text(
                        '1. Toca «Solo P»: la línea se acerca a la meta pero se queda corta para siempre. '
                        'Ese es el error permanente.\n\n'
                        '2. Toca «P + I»: la integral va sumando el error hasta que por fin llega a la meta exacta.\n\n'
                        '3. Toca «Mucho P»: con demasiada ganancia se pasa de la meta y oscila (overshoot).\n\n'
                        '4. Toca «PID» y sube D: la derivada frena el vaivén y la respuesta queda suave y rápida.',
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

  Widget _legend(Color c, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 5, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
        ],
      );

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

  Widget _presetChip(String name, List<double> g) {
    final selected = (_sim.kp - g[0]).abs() < 0.001 && (_sim.ki - g[1]).abs() < 0.001 && (_sim.kd - g[2]).abs() < 0.001;
    return GestureDetector(
      onTap: () => _applyPreset(g),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppTheme.primaryDark : AppTheme.borderColor, width: 2),
          boxShadow: [BoxShadow(color: selected ? AppTheme.primaryDark : AppTheme.borderColor, offset: const Offset(0, 3), blurRadius: 0)],
        ),
        child: Text(name,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: selected ? Colors.white : AppTheme.primaryBlue)),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 2),
          boxShadow: const [BoxShadow(color: AppTheme.borderColor, offset: Offset(0, 4), blurRadius: 0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _sliderBlock(String label, double value, double min, double max, Color color, ValueChanged<double> onChanged) {
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
              child: Text(value.toStringAsFixed(2),
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
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _PidGraphPainter extends CustomPainter {
  final List<double> history;
  final double target;

  const _PidGraphPainter({required this.history, required this.target});

  static const double _minV = -0.3;
  static const double _maxV = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    double yFor(double v) => size.height - ((v - _minV) / (_maxV - _minV)) * size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF1F7FF));

    // Cuadrícula: líneas cada 0.5 y cada segundo (60 muestras)
    final grid = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;
    for (var v = 0.0; v <= 1.5; v += 0.5) {
      canvas.drawLine(Offset(0, yFor(v)), Offset(size.width, yFor(v)), grid);
    }
    for (var s = 1; s < 4; s++) {
      final x = size.width * (s * 60 / (PidSimulation.historyLength - 1));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    // Meta (línea punteada dorada)
    final targetPaint = Paint()
      ..color = AppTheme.accentGold
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final ty = yFor(target);
    for (var x = 0.0; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, ty), Offset(x + 8, ty), targetPaint);
    }

    if (history.length < 2) return;

    final path = Path();
    for (var i = 0; i < history.length; i++) {
      final x = size.width * (i / (PidSimulation.historyLength - 1));
      final y = yFor(history[i]).clamp(0.0, size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppTheme.primaryBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Punto actual
    final lastX = size.width * ((history.length - 1) / (PidSimulation.historyLength - 1));
    final lastY = yFor(history.last).clamp(0.0, size.height);
    canvas.drawCircle(Offset(lastX, lastY), 7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = AppTheme.primaryBlue);
  }

  @override
  bool shouldRepaint(covariant _PidGraphPainter old) => true;
}
