import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';

/// Hands-on Ohm's law simulator: V = I * R.
///
/// The learner drags voltage and resistance, and sees the resulting current
/// both as a number and as the brightness of a simulated light bulb.
class OhmsLawSimulatorScreen extends StatefulWidget {
  const OhmsLawSimulatorScreen({super.key});

  @override
  State<OhmsLawSimulatorScreen> createState() => _OhmsLawSimulatorScreenState();
}

class _OhmsLawSimulatorScreenState extends State<OhmsLawSimulatorScreen> {
  double _voltage = 9; // volts
  double _resistance = 220; // ohms

  double get _current => _voltage / _resistance; // amps
  double get _maxCurrent => 24 / 10; // volts max / resistance min
  double get _glowIntensity => (_current / _maxCurrent).clamp(0.0, 1.0);

  String get _currentLabel {
    final milliAmps = _current * 1000;
    if (milliAmps < 1000) {
      return '${milliAmps.toStringAsFixed(1)} mA';
    }
    return '${_current.toStringAsFixed(2)} A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ley de Ohm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  _buildBulb(),
                  const SizedBox(height: 20),
                  Text(
                    _currentLabel,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                  ),
                  const Text('Corriente (I = V / R)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sliderBlock(
                    label: 'Voltaje',
                    value: _voltage,
                    min: 1,
                    max: 24,
                    unit: 'V',
                    color: AppTheme.accentOrange,
                    onChanged: (v) => setState(() => _voltage = v),
                  ),
                  const SizedBox(height: 22),
                  _sliderBlock(
                    label: 'Resistencia',
                    value: _resistance,
                    min: 10,
                    max: 1000,
                    unit: 'Ω',
                    color: AppTheme.accentPurple,
                    onChanged: (v) => setState(() => _resistance = v),
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
                    'La Ley de Ohm dice que la corriente (I) que pasa por un circuito '
                    'depende del voltaje (V) que lo empuja y de la resistencia (R) que se '
                    'le opone: I = V / R. Sube el voltaje y el foco brilla más fuerte; '
                    'sube la resistencia y el foco se apaga, aunque el voltaje no cambie.',
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

  Widget _buildBulb() {
    return AnimatedContainer(
      duration: AppTheme.animNormal,
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(AppTheme.bgSecondary, AppTheme.accentGold, _glowIntensity),
        boxShadow: _glowIntensity > 0.05
            ? [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: _glowIntensity * 0.7),
                  blurRadius: 20 + _glowIntensity * 30,
                  spreadRadius: _glowIntensity * 10,
                ),
              ]
            : [],
      ),
      child: Icon(
        Icons.lightbulb_rounded,
        size: 48,
        color: Color.lerp(AppTheme.textMuted, Colors.white, _glowIntensity),
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
            Text('${value.toStringAsFixed(0)} $unit',
                style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
