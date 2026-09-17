import 'package:evacua/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra las funciones principales de EVACUA', (tester) async {
    await tester.pumpWidget(const EvacuaApp());

    expect(find.text('EVACUA'), findsOneWidget);
    expect(find.text('Escanear ubicación'), findsOneWidget);
    expect(find.text('Consultar ruta'), findsOneWidget);
    expect(find.text('Equipos cercanos'), findsOneWidget);
  });
}

