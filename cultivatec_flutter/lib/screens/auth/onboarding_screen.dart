import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';

/// Onboarding en 3 pasos guiado por Wokov:
/// 0 = bienvenida · 1 = meta diaria · 2 = nombre del robot.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _stepCount = 3;
  static const _goalInfo = <int, (String, String)>{
    20: ('Relajada', 'Para empezar con calma'),
    30: ('Normal', 'El ritmo recomendado'),
    50: ('Seria', 'Para avanzar más rápido'),
    100: ('Intensa', 'Para inventores decididos'),
  };
  static const _wokovLines = [
    '¡Hola! Soy Wokov',
    '¿Cuánta XP al día?',
    '¡Ponle nombre!',
  ];

  int _step = 0;
  int _goal = DailyGoalService.goalXp.value;
  final _robotNameCtrl = TextEditingController(text: 'Mi Robot');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BlueConfetti.show(context, style: ConfettiStyle.rain, count: 50);
    });
  }

  @override
  void dispose() {
    _robotNameCtrl.dispose();
    super.dispose();
  }

  void _go(int step) {
    SoundService.playClick();
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
  }

  Future<void> _finishOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await DailyGoalService.setGoal(_goal);
      await auth.updateProfile({
        'robotConfig': const RobotConfig(skinImage: 'skin_1').toMap(),
        'robotName': _robotNameCtrl.text.trim().isEmpty ? 'Mi Robot' : _robotNameCtrl.text.trim(),
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppTheme.accentRed,
            content: const Text('No pudimos guardar tu robot. Revisa tu conexión e inténtalo otra vez.',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(top: -70, left: -60, child: _bubble(220, 0.07)),
          Positioned(top: 140, right: -80, child: _bubble(200, 0.06)),
          Positioned(bottom: 220, left: -90, child: _bubble(240, 0.05)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: List.generate(_stepCount, (i) {
                      final on = i <= _step;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          height: 9,
                          margin: EdgeInsets.only(right: i == _stepCount - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: on ? Colors.white : Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: keyboardOpen
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 4),
                          child: SizedBox(
                            height: 195,
                            child: WokovMascot(
                              pose: WokovPose.idle,
                              size: 190,
                              message: _wokovLines[_step],
                              idleAction: WokovAction.wave,
                              actionInterval: const Duration(seconds: 5),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                      child: switch (_step) {
                        0 => _buildWelcome(),
                        1 => _buildGoal(),
                        _ => _buildName(),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );

  Widget _sheet({required Key key, required List<Widget> children}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.fromLTRB(24, 26, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _title(String t) => Text(t,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary));

  Widget _subtitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, height: 1.35)),
      );

  // --- Paso 0: bienvenida ---------------------------------------------------
  Widget _buildWelcome() {
    Widget feature(IconData icon, String text) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.cardDecoration(radius: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppTheme.iceBlue, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ),
            ],
          ),
        );

    return _sheet(
      key: const ValueKey('step0'),
      children: [
        _title('¡Bienvenido a Wokov!'),
        _subtitle('Antes de entrar a la Academia Robótica, vamos a dejar todo listo.'),
        const SizedBox(height: 20),
        feature(Icons.memory_rounded, 'Aprende robótica y electrónica jugando'),
        feature(Icons.local_fire_department_rounded, 'Gana XP y mantén tu racha diaria'),
        feature(Icons.emoji_events_rounded, 'Compite y reta a tus amigos'),
        const SizedBox(height: 10),
        CartoonButton.success(text: '¡Empezar!', icon: Icons.rocket_launch_rounded, onPressed: () => _go(1)),
      ],
    );
  }

  // --- Paso 1: meta diaria ----------------------------------------------------
  Widget _buildGoal() {
    return _sheet(
      key: const ValueKey('step1'),
      children: [
        _title('Elige tu meta diaria'),
        _subtitle('Puedes cambiarla cuando quieras en Configuración.'),
        const SizedBox(height: 18),
        for (final xp in DailyGoalService.goalOptions) _goalTile(xp),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: CartoonButton.secondary(text: 'Volver', onPressed: () => _go(0))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: CartoonButton(text: 'Continuar', onPressed: () => _go(2))),
          ],
        ),
      ],
    );
  }

  Widget _goalTile(int xp) {
    final sel = xp == _goal;
    final info = _goalInfo[xp] ?? ('Meta', '');
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() => _goal = xp);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppTheme.iceBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppTheme.primaryBlue : AppTheme.borderColor, width: 2),
          boxShadow: [BoxShadow(color: sel ? AppTheme.primaryBlue : AppTheme.borderColor, offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.$1,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: sel ? AppTheme.primaryBlue : AppTheme.textPrimary)),
                  Text(info.$2,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primaryBlue : AppTheme.bgPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('$xp XP',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: sel ? Colors.white : AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Paso 2: nombre del robot -----------------------------------------------
  Widget _buildName() {
    return _sheet(
      key: const ValueKey('step2'),
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBlue, width: 4),
              boxShadow: const [BoxShadow(color: AppTheme.primaryDark, offset: Offset(0, 5), blurRadius: 0)],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/skin_1.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_rounded, size: 52, color: AppTheme.primaryBlue),
                ),
              ),
            ),
          ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 14),
        const Text('Este es tu primer robot. ¡Desbloquearás más diseños mientras aprendes!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
        const SizedBox(height: 20),
        _title('¡Dale un nombre a tu robot!'),
        const SizedBox(height: 16),
        TextField(
          controller: _robotNameCtrl,
          textAlign: TextAlign.center,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 19),
          decoration: InputDecoration(
            hintText: 'Mi Robot',
            hintStyle: const TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: AppTheme.bgPrimary,
            counterStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMuted),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.borderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.borderColor, width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2.5)),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: CartoonButton.secondary(text: 'Volver', onPressed: () => _go(1))),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CartoonButton.success(
                text: '¡Listo!',
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _finishOnboarding,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
