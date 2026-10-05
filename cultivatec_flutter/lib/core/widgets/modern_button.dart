import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';

/// Botón heredado: ahora es un envoltorio del [CartoonButton] 3D para que
/// toda la app tenga UN solo estilo de botón. Misma API de siempre.
class ModernButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const ModernButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return isPrimary
        ? CartoonButton(text: label, icon: icon, onPressed: onPressed, isLoading: isLoading)
        : CartoonButton.secondary(text: label, icon: icon, onPressed: onPressed, isLoading: isLoading);
  }
}
