import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/screens/simulators/ohms_law_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/diode_rectifier_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/transistor_switch_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/timer555_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/arm_kinematics_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/pid_simulator_screen.dart';

/// Entry point for every hands-on simulator in Wokov.
///
/// Only a handful of simulators are fully built today. The rest of the
/// entries are shown as "próximamente" (coming soon) so the roadmap from
/// the curriculum stays visible in the app while they get built one by one.
class SimulatorsHubScreen extends StatelessWidget {
  const SimulatorsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SimulatorEntry>[
      _SimulatorEntry(
        title: 'Ley de Ohm',
        subtitle: 'Mueve el voltaje y la resistencia y observa la corriente',
        icon: Icons.bolt_rounded,
        color: AppTheme.primaryBlue,
        builder: (_) => const OhmsLawSimulatorScreen(),
      ),
      _SimulatorEntry(
        title: 'Diodo Rectificador',
        subtitle: 'Cómo un diodo convierte corriente alterna en pulsante',
        icon: Icons.show_chart_rounded,
        color: AppTheme.accentCyan,
        builder: (_) => const DiodeRectifierSimulatorScreen(),
      ),
      _SimulatorEntry(
        title: 'Transistor como Interruptor',
        subtitle: 'Enciende y apaga un LED controlando la base',
        icon: Icons.toggle_on_rounded,
        color: AppTheme.toneIndigo,
        builder: (_) => const TransistorSwitchSimulatorScreen(),
      ),
      _SimulatorEntry(
        title: 'Temporizador 555',
        subtitle: 'El R y el C controlan qué tan rápido parpadea el LED',
        icon: Icons.timer_rounded,
        color: AppTheme.toneAzure,
        builder: (_) => const Timer555SimulatorScreen(),
      ),
      _SimulatorEntry(
        title: 'Control PID',
        subtitle: 'Mira el error que nunca desaparece, y cómo arreglarlo',
        icon: Icons.tune_rounded,
        color: AppTheme.primaryBlue,
        builder: (_) => const PidSimulatorScreen(),
      ),
      const _SimulatorEntry(
        title: 'Red Neuronal Básica',
        subtitle: 'Próximamente',
        icon: Icons.hub_rounded,
        color: AppTheme.textMuted,
        builder: null,
      ),
      _SimulatorEntry(
        title: 'Cinemática de un Brazo Robótico',
        subtitle: 'Mueve los ángulos y mira a dónde llega la mano, en tiempo real',
        icon: Icons.precision_manufacturing_rounded,
        color: AppTheme.accentPurple,
        builder: (_) => const ArmKinematicsSimulatorScreen(),
      ),
    ];

    final available = items.where((e) => e.builder != null).length;

    return Scaffold(
      body: AnimatedBackground(
        child: Column(
          children: [
            BlueHeader(
              title: 'Simuladores',
              subtitle: '$available listos para probar · el resto llega pronto',
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                ),
              ),
              mascot: const SizedBox(
                width: 92,
                height: 92,
                child: WokovMascot(pose: WokovPose.build, size: 92, floating: false, tappable: false),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _SimulatorCard(
                    item: item,
                    onTap: item.builder == null
                        ? null
                        : () {
                            SoundService.playClick();
                            Navigator.push(context, AppTheme.smoothRoute(item.builder!(context)));
                          },
                  )
                      .animate()
                      .fadeIn(delay: (60 * index).ms, duration: 350.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutBack);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta 3D de un simulador. Si aún no existe se ve apagada y con candado.
class _SimulatorCard extends StatefulWidget {
  final _SimulatorEntry item;
  final VoidCallback? onTap;
  const _SimulatorCard({required this.item, required this.onTap});

  @override
  State<_SimulatorCard> createState() => _SimulatorCardState();
}

class _SimulatorCardState extends State<_SimulatorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final enabled = widget.onTap != null;
    final color = enabled ? item.color : const Color(0xFF9DB4D8);
    final dark = Color.lerp(color, Colors.black, 0.3)!;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        margin: EdgeInsets.only(top: _pressed ? 5 : 0, bottom: _pressed ? 14 : 19),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(color, Colors.white, 0.12)!, color],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: _pressed ? const [] : [BoxShadow(color: dark, blurRadius: 0, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -14,
              bottom: -24,
              child: Icon(item.icon, size: 100, color: Colors.white.withValues(alpha: 0.13)),
            ),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                  ),
                  child: Icon(enabled ? item.icon : Icons.lock_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text(item.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (enabled)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.play_arrow_rounded, color: color, size: 24),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulatorEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext context)? builder;

  const _SimulatorEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}
