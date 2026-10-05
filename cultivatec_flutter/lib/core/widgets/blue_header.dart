import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';

/// Encabezado azul de pantalla completa (degradado marino → azul de marca),
/// con esquinas inferiores redondeadas, sombra sólida y círculos decorativos.
///
/// Se usa en todas las pestañas para que la app se sienta de una sola familia.
/// Respeta la zona segura superior (notch / barra de estado) por sí mismo.
class BlueHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Widget a la derecha del título (por ejemplo, una campana o un botón).
  final Widget? trailing;

  /// Wokov u otra ilustración a la derecha.
  final Widget? mascot;

  /// Contenido debajo del título (barra de XP, pestañas segmentadas, etc.).
  final Widget? bottom;
  final bool insetTop;

  const BlueHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.mascot,
    this.bottom,
    this.insetTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final top = insetTop ? MediaQuery.of(context).padding.top : 0.0;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(34), bottomRight: Radius.circular(34)),
        boxShadow: [BoxShadow(color: AppTheme.navyDeep, offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -40, child: _dot(190, 0.08)),
          Positioned(bottom: -70, left: -50, child: _dot(160, 0.06)),
          Positioned(top: top + 70, left: 150, child: _dot(46, 0.07)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 29, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.6, height: 1.1)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 5),
                            Text(subtitle!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFBFDDFF), height: 1.3)),
                          ],
                        ],
                      ),
                    ),
                    if (mascot != null) ...[const SizedBox(width: 8), mascot!],
                    if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                  ],
                ),
                if (bottom != null) ...[const SizedBox(height: 14), bottom!],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}
