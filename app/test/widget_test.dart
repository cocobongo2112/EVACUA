import 'package:flutter_test/flutter_test.dart';
import 'package:evacua/app/app.dart';

void main() {
  testWidgets('EVACUA muestra la pantalla de bienvenida', (tester) async {
    await tester.pumpWidget(const EvacuaApp());
    expect(find.text('EVACUA'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('Bienvenida navega al inicio de sesión', (tester) async {
    await tester.pumpWidget(const EvacuaApp());
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido a EVACUA'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });

  testWidgets('Bienvenida navega al registro', (tester) async {
    await tester.pumpWidget(const EvacuaApp());
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Registro EVACUA'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });
}
