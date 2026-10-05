import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';

/// Tarjeta "3D" plana: fondo blanco, borde azul claro de 2 px y sombra sólida
/// debajo. (Antes era glassmorphism; se mantiene el nombre y la API para que
/// todos los usos sigan funcionando.)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  /// Resalta la tarjeta con borde azul fuerte.
  final bool hasGlow;

  /// Color de fondo opcional (por defecto blanco).
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusLg,
    this.hasGlow = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(
        color: color,
        border: hasGlow ? AppTheme.primaryLight : AppTheme.borderColor,
        radius: borderRadius,
      ),
      child: child,
    );
  }
}
