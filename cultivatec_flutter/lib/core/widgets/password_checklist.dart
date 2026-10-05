import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/validators.dart';

/// Indicaciones en vivo para crear una contraseña: medidor de fuerza en
/// azules + lista de reglas que se van marcando con una palomita azul.
class PasswordChecklist extends StatelessWidget {
  final String password;
  const PasswordChecklist({super.key, required this.password});

  static const _labels = ['', 'Débil', 'Regular', 'Buena', '¡Fuerte!'];

  Color _barColor(int s) {
    switch (s) {
      case 1:
        return AppTheme.accentRed;
      case 2:
        return AppTheme.accentOrange;
      case 3:
        return AppTheme.primaryLight;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = PasswordRules.evaluate(password);
    final s = password.isEmpty ? 0 : r.strength.clamp(1, 4);
    final color = _barColor(s);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(color: AppTheme.bgPrimary, radius: 18, raised: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(4, (i) {
                    final on = i < s;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 8,
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                        decoration: BoxDecoration(
                          color: on ? color : AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 62,
                child: Text(
                  password.isEmpty ? 'Seguridad' : _labels[s],
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: password.isEmpty ? AppTheme.textMuted : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Rule(ok: r.minLength, text: 'Mínimo 8 caracteres'),
          _Rule(ok: r.hasLetter, text: 'Al menos una letra'),
          _Rule(ok: r.hasDigit, text: 'Al menos un número'),
          _Rule(ok: r.hasUpperAndLower, text: 'Mayúsculas y minúsculas (¡más segura!)', optional: true),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final bool ok;
  final String text;
  final bool optional;
  const _Rule({required this.ok, required this.text, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? AppTheme.primaryBlue : Colors.white,
              border: Border.all(color: ok ? AppTheme.primaryBlue : AppTheme.borderColor, width: 2),
            ),
            child: ok
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    .animate(key: ValueKey('ok_$text'))
                    .scale(begin: const Offset(0.3, 0.3), duration: 260.ms, curve: Curves.easeOutBack)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ok ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
          if (optional && !ok)
            const Text('opcional', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
