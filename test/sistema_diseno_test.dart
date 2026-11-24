import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarpon_mx/compartido/widgets/controles_app.dart';
import 'package:tarpon_mx/compartido/widgets/estado_operacion.dart';
import 'package:tarpon_mx/compartido/widgets/logo_tarpon.dart';
import 'package:tarpon_mx/nucleo/colores_app.dart';
import 'package:tarpon_mx/nucleo/tema_app.dart';

void main() {
  testWidgets('Tema oscuro aplicado a tarjeta, títulos y acciones', (
    tester,
  ) async {
    var pulsaciones = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: Scaffold(
          body: TarjetaApp(
            child: Column(
              children: [
                const EncabezadoApp(
                  titulo: 'Prueba',
                  descripcion: 'Descripción',
                ),
                BotonPrincipal(texto: 'Aceptar', alPulsar: () => pulsaciones++),
                const BotonSecundario(texto: 'Cancelar', alPulsar: null),
              ],
            ),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(TarjetaApp));
    final tema = Theme.of(context);
    expect(tema.brightness, Brightness.dark);
    expect(tema.scaffoldBackgroundColor, ColoresApp.fondo);
    expect(tema.cardTheme.color, ColoresApp.tarjeta);
    expect(tema.textTheme.bodyMedium?.fontFamily, 'Inter');
    await tester.tap(find.text('Aceptar'));
    expect(pulsaciones, 1);
  });

  testWidgets(
    'Logotipo original y compacto conservan proporciones y alineación',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LogoTharpon(key: Key('original'), ancho: 180, alto: 112),
                LogoTharpon(
                  key: Key('compacto'),
                  formato: FormatoLogo.compacto,
                  variante: VarianteLogo.fondoOscuro,
                  ancho: 180,
                  alto: 80,
                  alineacion: Alignment.centerLeft,
                ),
              ],
            ),
          ),
        ),
      );
      final original = find.descendant(
        of: find.byKey(const Key('original')),
        matching: find.byType(Image),
      );
      expect(tester.widget<Image>(original).color, isNull);
      final compacto = find.byKey(const Key('compacto'));
      final recorte = find.descendant(
        of: compacto,
        matching: find.byType(ClipRect),
      );
      final imagen = find.descendant(
        of: compacto,
        matching: find.byType(Image),
      );
      final dimensiones = tester.getSize(imagen);
      expect(
        dimensiones.width / dimensiones.height,
        closeTo(1595 / 986, 0.005),
      );
      expect(tester.getSize(recorte).height, lessThan(dimensiones.height));
      expect(tester.getTopLeft(recorte).dx, tester.getTopLeft(compacto).dx);
      expect(tester.widget<Image>(imagen).color, ColoresApp.textoPrincipal);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Movimiento reducido conserva el indicador de carga estático', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: AparicionApp(
              child: EstadoOperacion(
                tipo: TipoEstadoOperacion.carga,
                mensaje: 'Cargando…',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    expect(find.text('Cargando…'), findsOneWidget);
  });
}
