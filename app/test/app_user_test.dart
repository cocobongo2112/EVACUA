import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/models/app_user.dart';

void main() {
  test('AppUser crea usuario normal desde mapa', () {
    final user = AppUser.fromMap(
      'uid-1',
      {
        'name': 'Felipe',
        'email': 'felipe@evacua.mx',
        'role': 'user',
        'active': true,
      },
    );

    expect(user.uid, 'uid-1');
    expect(user.name, 'Felipe');
    expect(user.role, 'user');
    expect(user.active, isTrue);
    expect(user.isAdmin, isFalse);
  });

  test('AppUser identifica rol administrador', () {
    const user = AppUser(
      uid: 'admin-1',
      name: 'Administrador',
      email: 'admin@evacua.mx',
      role: 'admin',
      active: true,
    );

    expect(user.isAdmin, isTrue);
    expect(user.toMap()['role'], 'admin');
  });

  test('AppUser usa valores seguros cuando faltan campos', () {
    final user = AppUser.fromMap(
      'uid-2',
      {'email': 'usuario@evacua.mx'},
    );

    expect(user.role, 'user');
    expect(user.active, isTrue);
    expect(user.name, '');
  });
}
