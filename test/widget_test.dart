import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tharpom_mx/main.dart';

void main() {
  // Agrupamos las pruebas principales de THARPOM MX.
  group('Pruebas de THARPOM MX', () {
    // Comprueba que la aplicación inicia correctamente.
    testWidgets('La aplicación muestra la pantalla de inicio', (
      WidgetTester tester,
    ) async {
      // Inicia la aplicación dentro del entorno de pruebas.
      await tester.pumpWidget(const TharpomMX());

      // Espera a que se construyan las pantallas.
      await tester.pumpAndSettle();

      // Verifica que aparece el título de la aplicación.
      expect(find.text('THARPOM MX'), findsOneWidget);

      // Verifica que existe el menú de navegación inferior.
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
