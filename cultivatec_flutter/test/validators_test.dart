import 'package:flutter_test/flutter_test.dart';
import 'package:cultivatec_flutter/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rechaza vacío, sin @ y mal formado', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('leo.correo.com'), contains('@'));
      expect(Validators.email('leo@correo'), isNotNull);
    });
    test('acepta un correo válido', () {
      expect(Validators.email('leo@correo.com'), isNull);
      expect(Validators.email('  leo@correo.com  '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('exige 8 caracteres, letra y número', () {
      expect(Validators.newPassword(''), isNotNull);
      expect(Validators.newPassword('abc123'), contains('8'));
      expect(Validators.newPassword('12345678'), contains('letra'));
      expect(Validators.newPassword('abcdefgh'), contains('número'));
      expect(Validators.newPassword('robot1234'), isNull);
    });
  });

  group('PasswordRules.strength', () {
    test('crece con la complejidad', () {
      expect(PasswordRules.evaluate('abc').strength, lessThan(PasswordRules.evaluate('robot1234').strength));
      expect(PasswordRules.evaluate('Robot1234!').strength, 4);
    });
  });

  group('Validators.confirmPassword', () {
    test('detecta contraseñas distintas', () {
      expect(Validators.confirmPassword('robot1234', 'robot12345'), isNotNull);
      expect(Validators.confirmPassword('robot1234', 'robot1234'), isNull);
    });
  });

  group('Validators.username', () {
    test('largo mínimo y máximo', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('Leo'), isNull);
      expect(Validators.username('a' * 21), isNotNull);
    });
  });
}
