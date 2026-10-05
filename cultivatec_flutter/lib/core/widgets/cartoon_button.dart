import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';

/// Botón "físico" estilo Duolingo: color sólido, sombra sólida debajo y se
/// hunde al presionar. Por defecto es AZUL.
///
/// * `CartoonButton(text: ...)`            → azul (acción principal)
/// * `CartoonButton.success(text: ...)`    → verde brote (confirmar / continuar)
/// * `CartoonButton.secondary(text: ...)`  → blanco con borde azul
/// * `CartoonButton.danger(text: ...)`     → rojo
class CartoonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const CartoonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppTheme.primaryBlue,
    this.shadowColor = AppTheme.primaryDark,
    this.textColor = Colors.white,
    this.borderColor,
    this.isLoading = false,
    this.icon,
    this.height = 54,
  });

  const CartoonButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
  })  : color = AppTheme.accentGreen,
        shadowColor = AppTheme.accentGreenDark,
        textColor = Colors.white,
        borderColor = null;

  const CartoonButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
  })  : color = AppTheme.accentRed,
        shadowColor = AppTheme.accentRedDark,
        textColor = Colors.white,
        borderColor = null;

  const CartoonButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
  })  : color = Colors.white,
        shadowColor = AppTheme.borderColor,
        textColor = AppTheme.primaryBlue,
        borderColor = AppTheme.borderColor;

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

class _CartoonButtonState extends State<CartoonButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.isLoading;
  static const double _depth = 5;

  @override
  Widget build(BuildContext context) {
    final disabledNoCallback = widget.onPressed == null;
    final bg = disabledNoCallback ? const Color(0xFFD5E2F5) : widget.color;
    final shadow = disabledNoCallback ? const Color(0xFFBCCDE6) : widget.shadowColor;
    final fg = disabledNoCallback ? AppTheme.textMuted : widget.textColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!_disabled) setState(() => _pressed = true);
      },
      onTapUp: (_) {
        if (_disabled) return;
        setState(() => _pressed = false);
        SoundService.playClick();
        widget.onPressed!();
      },
      onTapCancel: () {
        if (_pressed) setState(() => _pressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: _pressed ? _depth : 0, bottom: _pressed ? 0 : _depth),
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: widget.borderColor != null && !disabledNoCallback
              ? Border.all(color: widget.borderColor!, width: 2)
              : null,
          boxShadow: _pressed ? const [] : [BoxShadow(color: shadow, offset: const Offset(0, _depth), blurRadius: 0)],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: fg == AppTheme.primaryBlue ? AppTheme.primaryBlue : Colors.white, strokeWidth: 3),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 22),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.text.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
