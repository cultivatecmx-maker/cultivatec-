import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';

/// Wokov armándose pieza por pieza (patas, brazos, cuerpo, cabeza, cara y
/// arranque). Es un GIF animado con transparencia; con «Reducir movimiento»
/// (o si falta el archivo) muestra a Wokov quieto.
class WokovAssembly extends StatelessWidget {
  final double height;
  const WokovAssembly({super.key, this.height = 200});

  static const _still = 'assets/images/wokov/main.webp';

  @override
  Widget build(BuildContext context) {
    final still = Image.asset(_still, height: height, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink());
    if (MotionSettings.shouldReduce(context)) return still;
    return Image.asset(
      'assets/images/wokov/robot_ensamblaje.gif',
      height: height,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => still,
    );
  }
}

/// Pantalla de carga inicial: Wokov armándose sobre fondo azul.
class WokovSplash extends StatelessWidget {
  final String message;
  const WokovSplash({super.key, this.message = 'Armando tu laboratorio…'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WokovAssembly(height: 230),
            const SizedBox(height: 8),
            const Text('Wokov',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(message,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(height: 22),
            const _BouncingDots(),
          ],
        ),
      ),
    );
  }
}

/// Indicador de carga pequeño con Wokov pensando (para listas y secciones).
class WokovLoading extends StatelessWidget {
  final String? message;
  final double size;
  const WokovLoading({super.key, this.message, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WokovMascot(
            size: size,
            tappable: false,
            floating: false,
            sequence: WokovSequences.thinking,
            frameDuration: const Duration(milliseconds: 700),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          ],
          const SizedBox(height: 12),
          const _BouncingDots(color: AppTheme.primaryBlue),
        ],
      ),
    );
  }
}

/// Estado vacío o de error con Wokov, título, mensaje y botón opcional.
///
/// ```dart
/// WokovEmptyState(
///   pose: WokovPose.sad,
///   title: 'No tienes amigos aún',
///   message: 'Busca a tus compañeros por su nombre de inventor.',
///   actionLabel: 'Buscar amigos',
///   onAction: () {},
/// )
/// ```
class WokovEmptyState extends StatelessWidget {
  final WokovPose pose;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double mascotSize;

  const WokovEmptyState({
    super.key,
    this.pose = WokovPose.curious,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.mascotSize = 140,
  });

  /// Atajo para errores con botón de reintentar.
  const WokovEmptyState.error({
    super.key,
    this.title = '¡Ups! Algo salió mal',
    this.message = 'Revisa tu conexión a internet e inténtalo otra vez.',
    this.actionLabel = 'Reintentar',
    this.onAction,
    this.mascotSize = 140,
  }) : pose = WokovPose.scared;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WokovMascot(pose: pose, size: mascotSize),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, height: 1.35)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: 220, child: CartoonButton(text: actionLabel!, onPressed: onAction)),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0, duration: 300.ms),
    );
  }
}

class _BouncingDots extends StatelessWidget {
  final Color color;
  const _BouncingDots({this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 11,
          height: 11,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true), delay: (i * 160).ms)
            .moveY(begin: 0, end: -8, duration: 380.ms, curve: Curves.easeInOut);
      }),
    );
  }
}
