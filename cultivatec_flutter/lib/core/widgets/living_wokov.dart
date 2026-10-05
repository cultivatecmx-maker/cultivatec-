import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';

/// Gestos que Wokov puede hacer encima de su animación continua.
enum WokovAction {
  none,

  /// Levanta el brazo derecho y lo agita (saludo).
  wave,

  /// Salta con los brazos abiertos (festejo).
  cheer,
}

/// Wokov "vivo": está hecho de capas (cuerpo, brazos, cabeza, brote, párpado)
/// y se anima con transformaciones, así que siempre se ve nítido.
///
/// Siempre activo: respira, el brote se mece, la cabeza se inclina un poco,
/// los brazos se balancean y parpadea en momentos al azar.
///
/// Además:
/// * [idleAction] + [actionInterval]: repite un gesto cada cierto tiempo.
/// * [reactionTick]: súbelo (`tick++`) para disparar [reaction] al instante,
///   por ejemplo cuando el usuario lo toca.
///
/// Respeta "Reducir movimiento": en ese caso se queda quieto.
class LivingWokov extends StatefulWidget {
  /// Alto en píxeles lógicos (el ancho se calcula con la proporción de las capas).
  final double size;
  final WokovAction idleAction;
  final Duration actionInterval;
  final int reactionTick;
  final WokovAction reaction;

  /// Súbelo (`tick++`) para que Wokov "hable" ~1.4 s moviendo la boca.
  final int talkTick;

  const LivingWokov({
    super.key,
    required this.size,
    this.idleAction = WokovAction.none,
    this.actionInterval = const Duration(seconds: 5),
    this.reactionTick = 0,
    this.reaction = WokovAction.cheer,
    this.talkTick = 0,
  });

  /// Proporción ancho/alto de las capas (298 × 472 px).
  static const double aspect = 298 / 472;

  @override
  State<LivingWokov> createState() => _LivingWokovState();
}

class _LivingWokovState extends State<LivingWokov> with TickerProviderStateMixin {
  static const _dir = 'assets/images/wokov/layers';

  // Puntos de giro (en píxeles de la capa original de 298 × 472).
  static const _pivSprout = Offset(150, 72);
  static const _pivHead = Offset(150, 275);
  static const _pivArmL = Offset(52, 284);
  static const _pivArmR = Offset(246, 284);
  static const _pivMouth = Offset(150, 202); // borde superior de la boca

  late final AnimationController _loop; // 6 s, se repite sin cortes
  late final AnimationController _act; // gesto puntual
  late final AnimationController _talk; // boca hablando
  WokovAction _current = WokovAction.none;
  final _rng = math.Random();
  Timer? _blinkTimer;
  Timer? _actionTimer;
  bool _blinking = false;
  bool _running = false;

  /// `null` = todavía comprobando; `false` = falta alguna capa (se muestra la
  /// imagen estática en vez de cuadros rojos de error).
  bool? _assetsOk;
  static const _layerNames = ['body', 'arm_l', 'arm_r', 'head', 'mouth', 'sprout', 'eye_closed'];

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _act = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) setState(() => _current = WokovAction.none);
      });
    _talk = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _checkAssets();
  }

  Future<void> _checkAssets() async {
    try {
      await Future.wait(_layerNames.map((n) => rootBundle.load('$_dir/$n.webp')));
      if (mounted) setState(() => _assetsOk = true);
    } catch (e) {
      debugPrint('LivingWokov: faltan capas en $_dir/ ($e). '
          'Declara "assets/images/wokov/layers/" en pubspec.yaml y reinicia la app COMPLETA '
          '(los assets nuevos no se cargan con hot reload).');
      if (mounted) setState(() => _assetsOk = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MotionSettings.shouldReduce(context);
    if (reduce && _running) {
      _stop();
    } else if (!reduce && !_running) {
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant LivingWokov old) {
    super.didUpdateWidget(old);
    if (old.reactionTick != widget.reactionTick) _play(widget.reaction);
    if (old.talkTick != widget.talkTick && _running) _talk.forward(from: 0);
    if (old.idleAction != widget.idleAction || old.actionInterval != widget.actionInterval) {
      _actionTimer?.cancel();
      _scheduleAction();
    }
  }

  void _start() {
    _running = true;
    _loop.repeat();
    _scheduleBlink();
    _scheduleAction(first: true);
  }

  void _stop() {
    _running = false;
    _loop.stop();
    _blinkTimer?.cancel();
    _actionTimer?.cancel();
    _act.stop();
    _talk.stop();
    _blinking = false;
    _current = WokovAction.none;
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2200 + _rng.nextInt(2800)), () async {
      if (!mounted || !_running) return;
      setState(() => _blinking = true);
      await Future<void>.delayed(const Duration(milliseconds: 130));
      if (!mounted) return;
      setState(() => _blinking = false);
      // A veces parpadea dos veces seguidas.
      if (_rng.nextInt(4) == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 190));
        if (!mounted || !_running) return;
        setState(() => _blinking = true);
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() => _blinking = false);
      }
      _scheduleBlink();
    });
  }

  void _scheduleAction({bool first = false}) {
    _actionTimer?.cancel();
    if (widget.idleAction == WokovAction.none || !_running) return;
    final delay = first ? const Duration(milliseconds: 700) : widget.actionInterval;
    _actionTimer = Timer(delay, () {
      if (!mounted || !_running) return;
      _play(widget.idleAction);
      _scheduleAction();
    });
  }

  void _play(WokovAction a) {
    if (a == WokovAction.none || !_running) return;
    _act.duration = a == WokovAction.wave ? const Duration(milliseconds: 1700) : const Duration(milliseconds: 950);
    setState(() => _current = a);
    _act.forward(from: 0);
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _actionTimer?.cancel();
    _loop.dispose();
    _act.dispose();
    _talk.dispose();
    super.dispose();
  }

  Alignment _align(Offset p) => Alignment(p.dx / 298 * 2 - 1, p.dy / 472 * 2 - 1);

  Widget _layer(String name, double w, double h) => Image.asset(
        '$_dir/$name.webp',
        width: w,
        height: h,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => SizedBox(width: w, height: h),
      );

  @override
  Widget build(BuildContext context) {
    final h = widget.size;
    final w = h * LivingWokov.aspect;

    // Plan B: si las capas no están, usa la imagen estática (sin cuadros rojos).
    if (_assetsOk == false) {
      return SizedBox(
        width: w,
        height: h,
        child: Image.asset(
          'assets/images/wokov/main.webp',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _act, _talk]),
        builder: (context, _) {
          final t = _loop.value;
          const tau = 2 * math.pi;
          // Con "reducir movimiento" se queda en su pose de reposo.
          final live = _running ? 1.0 : 0.0;
          final breath = math.sin(tau * t * 3) * live; // 2 s
          final sway = math.sin(tau * t * 2 + 1.0) * live; // 3 s
          final armSway = math.sin(tau * t * 3 + 0.9) * live;

          double armR = -0.09 - armSway * 0.035;
          double armL = 0.09 + armSway * 0.035;
          double headTilt = math.sin(tau * t + 0.4) * 0.018 * live;
          double hop = 0;
          double stretch = 0;

          final p = _act.value;
          if (_current == WokovAction.wave) {
            final env = math.min(1.0, math.min(p / 0.14, (1 - p) / 0.14)).clamp(0.0, 1.0);
            final wiggle = math.sin(p * tau * 4) * 0.2 * env;
            armR = armR + (-0.95 - armR) * env + wiggle;
            headTilt += -0.035 * env;
          } else if (_current == WokovAction.cheer) {
            final up = math.sin(math.pi * p);
            armL = armL + (0.8 - armL) * up;
            armR = armR + (-0.8 - armR) * up;
            hop = -up * h * 0.06;
            stretch = up * 0.045;
            headTilt += math.sin(p * tau) * 0.03;
          }

          final headDy = -breath * h * 0.0035;
          final sproutAngle = sway * 0.09 + (_current == WokovAction.cheer ? math.sin(p * tau * 2) * 0.12 : 0);

          // Boca: se abre y cierra (escala vertical desde su borde superior).
          // En reposo vale 1.0 y se ve exactamente como el dibujo original.
          var mouthScale = 1.0;
          if (_talk.isAnimating) {
            final tp = _talk.value;
            final env = math.min(1.0, math.min(tp / 0.1, (1 - tp) / 0.12)).clamp(0.0, 1.0);
            final open = math.sin(tp * math.pi * 7).abs(); // ~7 sílabas
            mouthScale = 1.0 + env * (open * 0.2 - (1 - open) * 0.62);
          }

          Widget head = Stack(
            clipBehavior: Clip.none,
            children: [
              _layer('head', w, h),
              Transform(
                alignment: _align(_pivMouth),
                transform: Matrix4.diagonal3Values(1, mouthScale, 1),
                child: _layer('mouth', w, h),
              ),
              if (_blinking) _layer('eye_closed', w, h),
              Transform.rotate(
                angle: sproutAngle,
                alignment: _align(_pivSprout),
                child: _layer('sprout', w, h),
              ),
            ],
          );
          head = Transform.translate(
            offset: Offset(0, headDy),
            child: Transform.rotate(angle: headTilt, alignment: _align(_pivHead), child: head),
          );

          final body = Stack(
            clipBehavior: Clip.none,
            children: [
              _layer('body', w, h),
              Transform.rotate(angle: armL, alignment: _align(_pivArmL), child: _layer('arm_l', w, h)),
              Transform.rotate(angle: armR, alignment: _align(_pivArmR), child: _layer('arm_r', w, h)),
              head,
            ],
          );

          // Respiración: se estira un poquito desde los pies.
          return Transform.translate(
            offset: Offset(0, hop),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.diagonal3Values(1 - stretch * 0.5, 1 + breath * 0.008 + stretch, 1),
              child: body,
            ),
          );
        },
      ),
    );
  }
}
