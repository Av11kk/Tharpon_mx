import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarpon_mx/main.dart';

/// Pruebas básicas de la navegación de Tarpon MX.
void main() {
  testWidgets('La aplicación inicia correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TarponMX());

    expect(find.byType(MaterialApp), findsOneWidget);

    expect(find.byKey(const Key('boton_menu')), findsOneWidget);

    expect(find.byKey(const Key('boton_perfil')), findsOneWidget);
  });

  testWidgets('El menú muestra los siete módulos', (WidgetTester tester) async {
    await tester.pumpWidget(const TarponMX());

    // Abre el menú desplegable.
    await tester.tap(find.byKey(const Key('boton_menu')));

    await tester.pumpAndSettle();

    // Verifica las opciones disponibles.
    for (final nombre in [
      'Inicio',
      'Especies',
      'Clima',
      'Mareas',
      'Mapa',
      'Equipo',
      'Consejos',
    ]) {
      expect(find.text(nombre), findsWidgets);
    }
  });

  testWidgets('El usuario puede navegar a Clima', (WidgetTester tester) async {
    await tester.pumpWidget(const TarponMX());

    await tester.tap(find.byKey(const Key('boton_menu')));

    await tester.pumpAndSettle();

    // Seleccionamos Clima desde el menú.
    await tester.tap(find.text('Clima').last);

    await tester.pumpAndSettle();

    // Verifica que el menú volvió a cerrarse.
    expect(find.byType(PopupMenuItem), findsNothing);
  });
}
