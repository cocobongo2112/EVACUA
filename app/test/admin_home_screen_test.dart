import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evacua/screens/admin/admin_home_screen.dart';
import 'package:evacua/services/firebase/auth_service.dart';

void main() {
  testWidgets('Admin Home muestra módulos administrativos', (
    WidgetTester tester,
  ) async {
    final authService = AuthService(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'admin-1',
          email: 'admin@evacua.mx',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AdminHomeScreen(authService: authService),
      ),
    );

    expect(find.text('Panel administrativo'), findsOneWidget);
    expect(find.text('Gestión de edificios'), findsOneWidget);
    expect(find.text('Gestión de zonas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Gestión de usuarios'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Gestión de usuarios'), findsOneWidget);
  });
}
