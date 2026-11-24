import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarpon_mx/compartido/servicios/servicio_geografico.dart';
import 'package:tarpon_mx/compartido/widgets/panel_geografico.dart';
import 'package:tarpon_mx/compartido/widgets/grafica_condiciones.dart';
import 'package:tarpon_mx/compartido/widgets/selector_zona.dart';
import 'package:tarpon_mx/modulos/condiciones/pantalla_condiciones.dart';
import 'package:tarpon_mx/nucleo/tema_app.dart';

Map<String, Object> _pronostico() => {
  'timezone': 'America/Merida',
  'current': {
    'time': '2026-11-24T08:00',
    'temperature_2m': 28,
    'apparent_temperature': 30,
    'weather_code': 2,
    'wind_speed_10m': 14,
    'wind_direction_10m': 90,
    'wave_height': .8,
    'wave_period': 5,
  },
  'hourly': {
    'time': [
      for (var i = 0; i < 24; i++)
        '2026-11-24T${i.toString().padLeft(2, '0')}:00',
    ],
    'temperature_2m': [for (var i = 0; i < 24; i++) 24 + i * .2],
    'wind_speed_10m': [for (var i = 0; i < 24; i++) 12 + i * .1],
    'precipitation_probability': [for (var i = 0; i < 24; i++) i * 2],
    'wave_height': [for (var i = 0; i < 24; i++) .5 + i * .01],
  },
};

void main() {
  test(
    'Aplicar localidad y costa publica ambas antes de consultar una sola vez',
    () async {
      final solicitudes = <Uri>[];
      final entorno = EntornoGeo(
        repositorio: RepositorioGeo(
          ClienteGeo(
            MockClient((r) async {
              solicitudes.add(r.url);
              return http.Response(jsonEncode(_pronostico()), 200);
            }),
          ),
        ),
      );
      addTearDown(entorno.dispose);
      await Future.wait([entorno.clima.value, entorno.mar.value]);
      solicitudes.clear();
      entorno.aplicarLocalidades(
        const Localidad('Tierra', 20, -90),
        const Localidad('Costa', 21, -91),
      );
      await Future.wait([entorno.clima.value, entorno.mar.value]);
      expect(solicitudes, hasLength(2));
      expect(
        solicitudes
            .singleWhere((u) => u.host == 'api.open-meteo.com')
            .queryParameters['latitude'],
        '20.0',
      );
      expect(
        solicitudes
            .singleWhere((u) => u.host == 'marine-api.open-meteo.com')
            .queryParameters['latitude'],
        '21.0',
      );
    },
  );

  testWidgets(
    'Condiciones cambia de métrica y abre los detalles completos en móvil',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final entorno = EntornoGeo(
        repositorio: RepositorioGeo(
          ClienteGeo(
            MockClient(
              (_) async => http.Response(jsonEncode(_pronostico()), 200),
            ),
          ),
        ),
      );
      addTearDown(entorno.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaApp.oscuro,
          home: Scaffold(body: PantallaCondiciones(entorno: entorno)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('28°'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
      final lista = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Lluvia'),
        200,
        scrollable: lista,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lluvia'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LineChart>(find.byType(LineChart))
            .data
            .lineBarsData
            .single
            .spots
            .first
            .y,
        16,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('detalle_avanzado')),
        300,
        scrollable: lista,
      );
      expect(find.textContaining('Sin proveedor configurado'), findsOneWidget);
      await tester.tap(find.byKey(const Key('detalle_avanzado')));
      await tester.pumpAndSettle();
      expect(find.text('Detalle avanzado'), findsOneWidget);
      expect(find.text('Detalles del clima'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('La gráfica respeta huecos y movimiento reducido', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: GraficaCondiciones(
              titulo: 'Prueba',
              pasos: [
                PasoGeo('2026-11-24T08:00', {'valor': 1}),
                PasoGeo('2026-11-24T09:00', {}),
                PasoGeo('2026-11-24T10:00', {'valor': 3}),
              ],
              campo: 'valor',
              unidad: ' m',
            ),
          ),
        ),
      ),
    );
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.single.spots[1], FlSpot.nullSpot);
    expect(chart.duration, Duration.zero);
  });

  testWidgets('Cancelar el selector no publica la selección en borrador', (
    tester,
  ) async {
    final entorno = EntornoGeo(
      repositorio: RepositorioGeo(
        ClienteGeo(
          MockClient(
            (r) async => http.Response(
              jsonEncode(
                r.url.path == '/v1/search'
                    ? {
                        'results': [
                          {
                            'name': 'Costa nueva',
                            'latitude': 21,
                            'longitude': -90,
                          },
                        ],
                      }
                    : _pronostico(),
              ),
              200,
            ),
          ),
        ),
      ),
    );
    addTearDown(entorno.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => configurarZona(context, entorno),
              child: const Text('Elegir zona'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Elegir zona'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Localidad'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Costa');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Costa nueva'));
    await tester.pumpAndSettle();
    expect(entorno.localidad.value, Localidad.carmen);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(entorno.localidad.value, Localidad.carmen);
    expect(entorno.costa.value, Localidad.carmen);
  });
}
