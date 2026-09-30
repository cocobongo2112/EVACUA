import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evacua/services/firebase/auth_service.dart';

void main() {
  group('AuthService', () {
    test('permite iniciar sesión', () async {
      final user = MockUser(uid: 'usuario-1', email: 'usuario@evacua.mx');
      final mockAuth = MockFirebaseAuth(mockUser: user);
      final service = AuthService(auth: mockAuth);
      final result =
          await service.signIn(email: 'usuario@evacua.mx', password: '123456');
      expect(result.user, isNotNull);
      expect(service.currentUser?.email, 'usuario@evacua.mx');
    });

    test('permite cerrar sesión', () async {
      final user = MockUser(uid: 'usuario-1', email: 'usuario@evacua.mx');
      final mockAuth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final service = AuthService(auth: mockAuth);
      expect(service.currentUser, isNotNull);
      await service.signOut();
      expect(service.currentUser, isNull);
    });

    test('permite registrar un usuario', () async {
      final service = AuthService(auth: MockFirebaseAuth());
      final result =
          await service.register(email: 'nuevo@evacua.mx', password: '123456');
      expect(result.user, isNotNull);
      expect(service.currentUser, isNotNull);
    });
  });
}
