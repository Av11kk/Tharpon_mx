import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Aplicación principal de Tarpon MX.
import 'package:tarpon_mx/main.dart';

// Pantalla utilizada para verificar la navegación.
import 'package:tarpon_mx/modulos/clima/pantalla_clima.dart';

/// =====================================================
/// PRUEBAS AUTOMATIZADAS DE TARPON MX
/// =====================================================
///
/// Estas pruebas comprueban:
///
/// 1. Que la aplicación inicia.
/// 2. Que solo existe una barra superior.
/// 3. Que el menú contiene los siete módulos.
/// 4. Que el banner Clima abre su pantalla.
/// 5. Que el botón de Perfil abre su apartado.
///
/// Las pruebas no dependen de que una API
/// meteorológica responda correctamente.

void main() {
  // ===================================================
  // PRUEBA 1: INICIO DE LA APLICACIÓN
  // ===================================================

  testWidgets('La aplicación inicia correctamente', (
    WidgetTester tester,
  ) async {
    // Construye nuestra aplicación.
    await tester.pumpWidget(const TarponMX());

    // Verifica que MaterialApp exista.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Comprueba que existe una barra superior
    // visible en la pantalla principal.
    expect(find.byType(AppBar), findsOneWidget);

    // Verifica los botones principales.
    expect(find.byKey(const Key('boton_menu')), findsOneWidget);

    expect(find.byKey(const Key('boton_perfil')), findsOneWidget);
  });

  // ===================================================
  // PRUEBA 2: MENÚ DESPLEGABLE
  // ===================================================

  testWidgets('El menú muestra los siete módulos', (WidgetTester tester) async {
    await tester.pumpWidget(const TarponMX());

    // Presiona el botón superior izquierdo.
    await tester.tap(find.byKey(const Key('boton_menu')));

    // Espera a que termine la animación del menú.
    await tester.pumpAndSettle();

    // Verifica que existan los siete módulos.
    for (final modulo in [
      'inicio',
      'especies',
      'clima',
      'mareas',
      'mapa',
      'equipo',
      'consejos',
    ]) {
      expect(find.byKey(Key('opcion_$modulo')), findsOneWidget);
    }
  });

  // ===================================================
  // PRUEBA 3: NAVEGACIÓN DESDE INICIO
  // ===================================================

  testWidgets('El banner Clima abre su módulo', (WidgetTester tester) async {
    // Inicia la aplicación.
    await tester.pumpWidget(const TarponMX());

    // Localiza el banner de Clima.
    final bannerClima = find.byKey(const Key('banner_clima'));

    // Verifica que el banner existe.
    expect(bannerClima, findsOneWidget);

    // Presiona el banner.
    await tester.tap(bannerClima);

    // Actualiza la interfaz.
    await tester.pump();

    // Busca la pantalla de Clima.
    //
    // skipOffstage: false permite localizar
    // widgets que están dentro de IndexedStack.
    final pantallaClima = find.byType(PantallaClima, skipOffstage: false);

    // Verificamos que la pantalla existe.
    expect(pantallaClima, findsOneWidget);

    // Comprobamos que IndexedStack ahora
    // muestra el módulo Clima.
    //
    // Según nuestro enum:
    // 0 = Inicio
    // 1 = Especies
    // 2 = Clima
    final contenedor = tester.widget<IndexedStack>(find.byType(IndexedStack));

    expect(contenedor.index, 2);
  });

  // ===================================================
  // PRUEBA 4: PERFIL
  // ===================================================

  testWidgets('El botón de Perfil abre su pantalla', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TarponMX());

    // Presiona el botón superior derecho.
    await tester.tap(find.byKey(const Key('boton_perfil')));

    // Espera la transición de navegación.
    await tester.pumpAndSettle();

    // Comprueba que apareció la pantalla.
    expect(find.text('Perfil del Usuario'), findsOneWidget);
  });
}
