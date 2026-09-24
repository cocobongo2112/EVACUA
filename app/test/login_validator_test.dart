import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/login_validator.dart';

void main() {
  group('LoginValidator - correo electrónico', () {
    test('rechaza un correo vacío', () {
      final result = LoginValidator.validateEmail('');

      expect(
        result,
        'El correo electrónico es obligatorio',
      );
    });

    test('rechaza un correo incorrecto', () {
      final result = LoginValidator.validateEmail('usuario');

      expect(
        result,
        'El correo electrónico no es válido',
      );
    });

    test('acepta un correo válido', () {
      final result = LoginValidator.validateEmail(
        'usuario@ejemplo.com',
      );

      expect(result, isNull);
    });
  });

  group('LoginValidator - contraseña', () {
    test('rechaza una contraseña corta', () {
      final result = LoginValidator.validatePassword('12345');

      expect(
        result,
        'La contraseña debe contener al menos 8 caracteres',
      );
    });

    test('acepta una contraseña válida', () {
      final result = LoginValidator.validatePassword(
        'Segura123',
      );

      expect(result, isNull);
    });
  });
}
