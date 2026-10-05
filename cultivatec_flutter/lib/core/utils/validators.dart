/// Reglas de validación de formularios (mensajes en español, tono amable).
class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  /// Devuelve un mensaje de error o `null` si el correo es válido.
  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Escribe tu correo.';
    if (!v.contains('@')) return 'Al correo le falta la @ (ej. leo@correo.com).';
    if (!_email.hasMatch(v)) return 'Ese correo no parece válido. Revísalo.';
    return null;
  }

  static String? username(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Elige tu nombre de inventor.';
    if (v.length < 3) return 'Debe tener al menos 3 letras o números.';
    if (v.length > 20) return 'Máximo 20 caracteres.';
    return null;
  }

  /// Contraseña al CREAR cuenta (aplica todas las reglas obligatorias).
  static String? newPassword(String value) {
    if (value.isEmpty) return 'Crea una contraseña secreta.';
    final r = PasswordRules.evaluate(value);
    if (!r.minLength) return 'Usa al menos 8 caracteres.';
    if (!r.hasLetter) return 'Agrega al menos una letra.';
    if (!r.hasDigit) return 'Agrega al menos un número.';
    return null;
  }

  /// Contraseña al INICIAR sesión (solo revisa que no esté vacía).
  static String? loginPassword(String value) {
    if (value.isEmpty) return 'Escribe tu contraseña.';
    return null;
  }

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Repite tu contraseña.';
    if (password != confirm) return 'Las contraseñas no coinciden.';
    return null;
  }
}

/// Resultado de evaluar una contraseña.
class PasswordRules {
  final bool minLength; // obligatoria
  final bool hasLetter; // obligatoria
  final bool hasDigit; // obligatoria
  final bool hasUpperAndLower; // recomendada
  final bool hasSpecial; // recomendada

  const PasswordRules({
    required this.minLength,
    required this.hasLetter,
    required this.hasDigit,
    required this.hasUpperAndLower,
    required this.hasSpecial,
  });

  bool get meetsRequired => minLength && hasLetter && hasDigit;

  /// 0 = vacía, 1 = débil, 2 = regular, 3 = buena, 4 = fuerte.
  int get strength {
    var score = 0;
    if (minLength) score++;
    if (hasLetter && hasDigit) score++;
    if (hasUpperAndLower) score++;
    if (hasSpecial) score++;
    return score;
  }

  static PasswordRules evaluate(String p) {
    return PasswordRules(
      minLength: p.length >= 8,
      hasLetter: RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]').hasMatch(p),
      hasDigit: RegExp(r'\d').hasMatch(p),
      hasUpperAndLower: RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(p) && RegExp(r'[a-záéíóúñ]').hasMatch(p),
      hasSpecial: RegExp(r'[^A-Za-z0-9ÁÉÍÓÚáéíóúÑñ\s]').hasMatch(p),
    );
  }
}
