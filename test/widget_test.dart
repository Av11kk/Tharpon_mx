import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:tharpom_mx/main.dart';

void main() {
  testWidgets('compara los tres estilos y muestra los datos simulados', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const TarponApp());

    expect(find.text('Océano nocturno'), findsOneWidget);
    expect(find.text('CLIMA DE EJEMPLO'), findsOneWidget);
    expect(find.byType(FCard), findsWidgets);

    await tester.tap(find.text('Cambiar estilo'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Costa clara'), findsOneWidget);

    await tester.tap(find.text('Cambiar estilo'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Trópico en movimiento'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Lugares para explorar'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Laguna de Términos'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Señuelo de superficie'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Equipo recomendado'), findsOneWidget);
    expect(find.text('Señuelo de superficie'), findsOneWidget);

    await tester.tap(find.text('Cambiar estilo'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Océano nocturno'), findsOneWidget);
  });
}
