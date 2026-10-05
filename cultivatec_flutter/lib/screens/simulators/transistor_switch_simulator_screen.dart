import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/glass_card.dart';

/// Simulates an NPN transistor used as a switch: a small signal on the base
/// decides whether a much larger current is allowed to flow from collector
/// to emitter, lighting an LED.
class TransistorSwitchSimulatorScreen extends StatefulWidget {
  const TransistorSwitchSimulatorScreen({super.key});

  @override
  State<TransistorSwitchSimulatorScreen> createState() => _TransistorSwitchSimulatorScreenState();
}

class _TransistorSwitchSimulatorScreenState extends State<TransistorSwitchSimulatorScreen> {
  bool _baseOn = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppTheme.accentGreen;
    const idleColor = AppTheme.borderColor;
    final wireColor = _baseOn ? activeColor : idleColor;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transistor como Interruptor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _componentChip('Batería', Icons.battery_full_rounded, AppTheme.primaryBlue),
                      _wire(wireColor),
                      _componentChip('Resistor', Icons.waves_rounded, AppTheme.accentPurple),
                      _wire(wireColor),
                      _buildLed(),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: Container(
                        width: 3,
                        height: _baseOn ? 44 : 20,
                        color: wireColor,
                      ),
                    ),
                  ),
                  _buildTransistor(),
                  const SizedBox(height: 10),
                  const Text('GND', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Señal en la base',
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          _baseOn ? 'Encendida — el transistor conduce' : 'Apagada — el transistor bloquea',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _baseOn,
                    onChanged: (v) => setState(() => _baseOn = v),
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
                    'Un transistor NPN se puede usar como un interruptor controlado '
                    'por voltaje. Cuando hay una señal en la base, el transistor '
                    'permite que la corriente fluya del colector al emisor, como si '
                    'cerraras un interruptor: el LED se enciende. Sin señal en la '
                    'base, el camino queda abierto y no pasa corriente, aunque la '
                    'batería siga conectada.',
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

  Widget _componentChip(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _wire(Color color) {
    return Container(width: 24, height: 3, color: color);
  }

  Widget _buildLed() {
    return AnimatedContainer(
      duration: AppTheme.animNormal,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _baseOn ? AppTheme.accentGold : AppTheme.bgSecondary,
        boxShadow: _baseOn
            ? [BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.6), blurRadius: 24, spreadRadius: 4)]
            : [],
      ),
      child: Icon(Icons.lightbulb_rounded, color: _baseOn ? Colors.white : AppTheme.textMuted),
    );
  }

  Widget _buildTransistor() {
    final color = _baseOn ? AppTheme.accentGreen : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_baseOn ? Icons.check_circle_rounded : Icons.block_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Text(_baseOn ? 'Conduciendo' : 'Bloqueado', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
