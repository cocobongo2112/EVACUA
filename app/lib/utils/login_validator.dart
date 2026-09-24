class LoginValidator {
  static String? validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'El correo electrónico no es válido';
    }

    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (value.length < 8) {
      return 'La contraseña debe contener al menos 8 caracteres';
    }

    return null;
  }
}
