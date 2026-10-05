import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';

/// Número que sube contando desde 0 (o desde [from]) hasta [value].
/// Con "reducir movimiento" muestra el valor final directamente.
class CountUpText extends StatelessWidget {
  final int value;
  final int from;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    this.from = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    final d = MotionSettings.shouldReduce(context) ? Duration.zero : duration;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from.toDouble(), end: value.toDouble()),
      duration: d,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$prefix${v.round()}$suffix', style: style),
    );
  }
}
