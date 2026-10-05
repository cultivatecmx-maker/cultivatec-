import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';

/// Todas las poses de Wokov disponibles (hoja de animación oficial).
///
/// Cada pose es un PNG/WebP transparente en `assets/images/wokov/`.
enum WokovPose {
  idle('main'),
  wave('wave'),
  walk('walk'),
  run('run'),
  jump('jump'),
  cheer('cheer_jump'),
  sit('sit'),
  pointSide('point_side'),
  pointUp('point_up'),
  think('think'),
  explain('explain'),
  dance('dance'),
  surprised('surprised'),
  scared('scared'),
  curious('curious'),
  armsUp('arms_up'),
  victory('victory'),
  build('build'),
  sad('sad'),
  angry('angry'),
  amazed('amazed'),
  excited('excited'),
  worried('worried'),
  tired('tired'),
  relieved('relieved'),
  shy('proud_shy'),
  puzzled('puzzled'),
  pondering('pondering'),
  focused('focused'),
  frustrated('frustrated'),
  relaxed('relaxed'),
  hold('hold'),
  hop('hop'),
  crouch('crouch'),
  fall('fall'),
  trip('trip'),
  crossed('crossed'),
  dash('dynamic');

  final String file;
  const WokovPose(this.file);

  String get asset => 'assets/images/wokov/$file.webp';
}

/// Retratos de expresiones (busto) de la hoja de Wokov: ideales para espacios
/// chicos (avatar en un globo, panel de resultado, chips).
enum WokovFace {
  feliz,
  emocionado,
  sonriendo,
  riendose,
  sorprendido,
  confundido,
  curioso,
  pensativo,
  concentrado,
  orgulloso,
  preocupado,
  triste,
  enojado,
  asustado,
  nervioso,
  cansado,
  frustrado,
  aliviado,
  entusiasmado,
  avergonzado;

  String get asset => 'assets/images/wokov/face_$name.webp';
}

/// Muestra un retrato de Wokov. Si el archivo no existe no pinta nada
/// (nunca muestra el cuadro rojo de error).
class WokovFaceImage extends StatelessWidget {
  final WokovFace face;
  final double size;
  const WokovFaceImage({super.key, required this.face, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        face.asset,
        key: ValueKey(face),
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Secuencias de poses listas para usar como "animación cuadro a cuadro".
class WokovSequences {
  /// Baile de celebración (se usa al terminar una lección o subir de nivel).
  static const celebrate = [
    WokovPose.victory,
    WokovPose.armsUp,
    WokovPose.dance,
    WokovPose.excited,
  ];

  /// Caminata/corrida (pantallas de carga y rachas).
  static const hustle = [WokovPose.walk, WokovPose.run];

  /// Pensando (mientras se carga algo).
  static const thinking = [WokovPose.think, WokovPose.pondering, WokovPose.curious];
}

/// Wokov, el robotito con brote, "vivo".
///
/// * Flota suavemente por sí solo.
/// * Al tocarlo salta y dice una frase.
/// * Cuando cambia [pose] hace un pequeño "squash & stretch".
/// * Con [sequence] reproduce varias poses en bucle (cuadro a cuadro).
class WokovMascot extends StatefulWidget {
  final WokovPose pose;
  final double size;
  final bool floating;
  final bool tappable;
  final bool flipHorizontal;

  /// Texto fijo en un globo sobre la cabeza (por ejemplo, un consejo).
  final String? message;

  /// Si se indica, ignora [pose] y alterna estas poses en bucle.
  final List<WokovPose>? sequence;
  final Duration frameDuration;

  /// Se muestra si el archivo de imagen no existe.
  final Widget? fallback;

  /// Solo con `pose: WokovPose.idle` (Wokov animado por capas): gesto que se
  /// repite cada [actionInterval] (por ejemplo `WokovAction.wave` para saludar).
  final WokovAction idleAction;
  final Duration actionInterval;

  const WokovMascot({
    super.key,
    this.pose = WokovPose.idle,
    required this.size,
    this.floating = true,
    this.tappable = true,
    this.flipHorizontal = false,
    this.message,
    this.sequence,
    this.frameDuration = const Duration(milliseconds: 420),
    this.fallback,
    this.idleAction = WokovAction.none,
    this.actionInterval = const Duration(seconds: 5),
  });

  @override
  State<WokovMascot> createState() => _WokovMascotState();
}

class _WokovMascotState extends State<WokovMascot> {
  static const _phrases = [
    '¡Vamos, tú puedes!',
    '¡Un paso más!',
    '¡Me encanta verte aprender!',
    '¡Sigamos explorando!',
    '¡Buena energía hoy!',
    '¡Hoy construimos algo genial!',
  ];

  final _rng = Random();
  Timer? _frameTimer;
  Timer? _bubbleTimer;
  Timer? _tapTimer;
  int _frame = 0;
  String? _bubbleText;
  WokovPose? _tapPose;
  int _reactionTick = 0;
  int _talkTick = 0;

  /// `idle` sin secuencia = Wokov animado por capas (respira, parpadea, saluda).
  bool get _living => widget.pose == WokovPose.idle && widget.sequence == null;

  @override
  void initState() {
    super.initState();
    _startSequence();
    // Si nace con un mensaje fijo, lo "dice" al aparecer.
    if (widget.message != null) {
      Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _talkTick++);
      });
    }
  }

  @override
  void didUpdateWidget(covariant WokovMascot old) {
    super.didUpdateWidget(old);
    if (old.message != widget.message && widget.message != null) _talkTick++;
    if (old.sequence != widget.sequence || old.frameDuration != widget.frameDuration) {
      _frameTimer?.cancel();
      _frame = 0;
      _startSequence();
    }
  }

  void _startSequence() {
    final seq = widget.sequence;
    if (seq == null || seq.length < 2) return;
    _frameTimer = Timer.periodic(widget.frameDuration, (_) {
      if (!mounted) return;
      setState(() => _frame = (_frame + 1) % seq.length);
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _bubbleTimer?.cancel();
    _tapTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    if (!widget.tappable) return;
    SoundService.playClick();
    setState(() {
      _bubbleText = _phrases[_rng.nextInt(_phrases.length)];
      _talkTick++;
      if (_living) {
        _reactionTick++; // salta con los brazos abiertos
      } else {
        _tapPose = WokovPose.cheer;
      }
    });
    _bubbleTimer?.cancel();
    _tapTimer?.cancel();
    _bubbleTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _bubbleText = null);
    });
    _tapTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _tapPose = null);
    });
  }

  WokovPose get _currentPose {
    if (_tapPose != null) return _tapPose!;
    final seq = widget.sequence;
    if (seq != null && seq.isNotEmpty) return seq[_frame % seq.length];
    return widget.pose;
  }

  @override
  Widget build(BuildContext context) {
    final pose = _currentPose;
    final text = _bubbleText ?? widget.message;

    final living = _living && _tapPose == null;
    Widget image = living
        ? Align(
            key: const ValueKey('living'),
            alignment: Alignment.bottomCenter,
            child: LivingWokov(
              size: widget.size,
              idleAction: widget.idleAction,
              actionInterval: widget.actionInterval,
              reactionTick: _reactionTick,
              talkTick: _talkTick,
            ),
          )
        : Image.asset(
            pose.asset,
            key: ValueKey(pose),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => widget.fallback ?? const SizedBox.shrink(),
          );
    if (widget.flipHorizontal) {
      image = Transform.flip(flipX: true, child: image);
    }

    Widget body = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.bottomCenter,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1).animate(anim),
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
        child: image,
      ),
    );

    // El Wokov animado por capas ya respira solo; no lo hacemos flotar además.
    if (widget.floating && !living && !MotionSettings.shouldReduce(context)) {
      body = body
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -6, duration: 1400.ms, curve: Curves.easeInOut);
    }

    return GestureDetector(
      onTap: widget.tappable ? _onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (text != null)
            Positioned(
              top: -38,
              child: _SpeechBubble(key: ValueKey(text), text: text),
            ),
          body,
        ],
      ),
    );
  }
}

/// Globo de diálogo con colita, estilo cómic.
class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: AppTheme.cardDecoration(border: AppTheme.primaryBlue, radius: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.3, end: 0, duration: 260.ms, curve: Curves.easeOutBack);
  }
}
