import 'package:cultivatec_flutter/core/widgets/wokov_props.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/celebrations.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';

/// Colócalo una vez dentro de la pantalla principal (por ejemplo como hijo del
/// `Stack` de HomeScreen). Revisa la cola de [CelebrationService] y, cuando la
/// pantalla está visible (no tapada por otra ruta), muestra la celebración con
/// confeti azul, sonido y Wokov.
class CelebrationHost extends StatefulWidget {
  const CelebrationHost({super.key});

  @override
  State<CelebrationHost> createState() => _CelebrationHostState();
}

class _CelebrationHostState extends State<CelebrationHost> {
  Timer? _timer;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted || _showing || !CelebrationService.hasPending) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return; // hay otra pantalla encima
    final c = CelebrationService.pop();
    if (c == null) return;
    _showing = true;
    try {
      await _show(c);
    } finally {
      _showing = false;
    }
  }

  Future<void> _show(Celebration c) async {
    switch (c.kind) {
      case CelebrationKind.levelUp:
        SoundService.playLevelUp();
        break;
      case CelebrationKind.achievement:
        SoundService.playAchievement();
        break;
      case CelebrationKind.dailyGoal:
        SoundService.playVictory();
        break;
    }

    final sequence = c.kind == CelebrationKind.levelUp ? WokovSequences.celebrate : null;
    // Subida de nivel: baile cuadro a cuadro. Logro y meta: Wokov animado saltando.
    final living = c.kind != CelebrationKind.levelUp;

    // El confeti se dibuja en el overlay raíz, por encima del diálogo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlueConfetti.show(context,
            style: ConfettiStyle.cannons, count: 130, duration: const Duration(milliseconds: 3200));
      }
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.brandBlue.withValues(alpha: 0.78),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: AppTheme.cardDecoration(radius: 32, border: AppTheme.primaryBlue),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c.kind == CelebrationKind.levelUp && c.number != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(14)),
                  child: Text('NIVEL ${c.number}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
                ),
              WokovSparkles(
                size: 190,
                child: WokovMascot(
                  pose: living ? WokovPose.idle : WokovPose.excited,
                  sequence: sequence,
                  idleAction: WokovAction.cheer,
                  actionInterval: const Duration(milliseconds: 1700),
                  size: 190,
                  tappable: false,
                ),
              ),
              const SizedBox(height: 8),
              Text(c.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(c.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, height: 1.35)),
              const SizedBox(height: 22),
              CartoonButton(text: '¡Genial!', onPressed: () => Navigator.of(ctx).pop()),
            ],
          ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
