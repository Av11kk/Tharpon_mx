import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tarpon_mx/compartido/servicios/servicio_geografico.dart';
import 'package:tarpon_mx/compartido/servicios/repositorio_cliente.dart';
import 'package:tarpon_mx/compartido/widgets/panel_geografico.dart';
import 'package:tarpon_mx/modulos/mapa/pantalla_mapa.dart';

void main() {
  testWidgets('Mapa muestra y abre solo los marcadores publicados', (
    tester,
  ) async {
    final entorno = EntornoGeo(
      repositorio: RepositorioGeo(
        ClienteGeo(
          MockClient(
            (_) async =>
                http.Response('{"current":{"time":"2026-11-22T09:00"}}', 200),
          ),
        ),
      ),
    );
    final puntos = ValueNotifier<Future<List<FilaCliente>>>(
      Future.value([
        {
          'id': 'visible',
          'nombre': 'Punto de prueba',
          'latitud': 18.64592,
          'longitud': -91.82991,
          'publicado': true,
        },
        {
          'id': 'oculto',
          'nombre': 'Punto oculto',
          'latitud': 18.64592,
          'longitud': -91.82991,
          'publicado': false,
        },
      ]),
    );
    addTearDown(entorno.dispose);
    addTearDown(puntos.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PantallaMapa(entorno: entorno, puntos: puntos, teselas: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final visible = find.byKey(const ValueKey('punto_visible'));
    expect(visible, findsOneWidget);
    expect(find.byKey(const ValueKey('punto_oculto')), findsNothing);
    await tester.tap(visible);
    await tester.pumpAndSettle();
    expect(find.text('Especies asociadas'), findsOneWidget);
  });

  test(
    'Clima interpreta series, nulos, huso de destino y unidades métricas',
    () async {
      final repo = RepositorioGeo(
        ClienteGeo(
          MockClient((solicitud) async {
            expect(solicitud.url.queryParameters['timezone'], 'auto');
            expect(solicitud.url.queryParameters['wind_speed_unit'], 'kmh');
            expect(
              solicitud.url.queryParameters['temperature_unit'],
              'celsius',
            );
            expect(solicitud.url.queryParameters['precipitation_unit'], 'mm');
            expect(solicitud.url.queryParameters['forecast_days'], '7');
            return http.Response(
              jsonEncode({
                'timezone': 'America/Merida',
                'current': {
                  'time': '2026-11-22T09:15',
                  'temperature_2m': 24.5,
                  'weather_code': 2,
                  'is_day': 1,
                },
                'hourly': {
                  'time': [
                    '2026-11-22T09:00',
                    '2026-11-22T10:00',
                    '2026-11-22T11:00',
                  ],
                  'temperature_2m': [24.5, 25, null],
                  'visibility': [10000],
                },
                'daily': {
                  'time': ['2026-11-22'],
                  'sunrise': ['2026-11-22T06:10'],
                  'temperature_2m_max': [28],
                },
              }),
              200,
            );
          }),
        ),
      );
      final datos = (await repo.clima(Localidad.carmen)).datos;
      expect(datos.zona, 'America/Merida');
      expect(datos.actual.numero('temperature_2m'), 24.5);
      expect(
        condicionGeo(datos.actual.numero('weather_code')),
        'Parcialmente nublado',
      );
      expect(horaGeo(datos.dias.single.texto('sunrise')!), '06:10');
      expect(datos.siguientes.first.hora, '2026-11-22T10:00');
      expect(datos.siguientes.first.numero('visibility'), isNull);
      expect(datos.siguientes.last.numero('temperature_2m'), isNull);
      expect(rumboViento(360), 'N');
      expect(rumboViento(270), 'O');
      expect(medidaGeo(1.25, ' m', decimales: 2), '1.25 m');
      expect(medidaGeo(null, ' mm'), '—');
    },
  );

  test(
    'Mar conserva separado el oleaje y el nivel MSL, aun con huecos',
    () async {
      final repo = RepositorioGeo(
        ClienteGeo(
          MockClient((solicitud) async {
            expect(solicitud.url.host, 'marine-api.open-meteo.com');
            expect(
              solicitud.url.queryParameters['hourly'],
              contains('sea_level_height_msl'),
            );
            return http.Response(
              '{"timezone":"America/Merida","hourly":{"time":["2026-11-22T00:00","2026-11-22T01:00"],"wave_height":[1.4,1.2],"sea_level_height_msl":[-0.2,null]}}',
              200,
            );
          }),
        ),
      );
      final datos = (await repo.mar(Localidad.carmen)).datos;
      expect(datos.horas.first.numero('wave_height'), 1.4);
      expect(datos.horas.first.numero('sea_level_height_msl'), -.2);
      expect(datos.horas.last.numero('sea_level_height_msl'), isNull);
      expect(repo.mareas, isNull);
    },
  );

  test('El proveedor de extremos conserva la fecha de consulta y normaliza el instante', () async {
    final proveedor = ProveedorMareasHttp(
      ClienteGeo(
        MockClient((solicitud) async {
          expect(solicitud.url.queryParameters['date'], '2026-11-22');
          return http.Response(
            '{"eventos":[{"hora":"2026-11-22T04:10:00-06:00","pleamar":false,"altura_m":0.2},{"hora":"2026-11-22T04:10:00","pleamar":true}]}',
            200,
          );
        }),
      ),
      Uri.https('example.com', '/mareas'),
    );
    final datos = await proveedor.extremos(Localidad.carmen, '2026-11-22');
    expect(datos.single.hora, DateTime.utc(2026, 11, 22, 10, 10));
    expect(datos.single.pleamar, isFalse);
    expect(datos.single.alturaMetros, .2);
  });

  test(
    'Caché comparte solicitudes y señala datos anteriores tras un fallo',
    () async {
      var reloj = DateTime.utc(2026, 11, 22);
      final cache = CacheGeo<String, int>(reloj: () => reloj);
      var llamadas = 0;
      Future<int> cargar() async => ++llamadas;
      final primera = cache.consultar('x', cargar);
      final segunda = cache.consultar('x', cargar, renovar: true);
      expect(identical(primera, segunda), isTrue);
      expect((await primera).datos, 1);
      expect((await cache.consultar('x', cargar)).datos, 1);
      reloj = reloj.add(const Duration(minutes: 16));
      final resultado = await cache.consultar(
        'x',
        () async => throw const ErrorProveedor(503),
      );
      expect(resultado.datos, 1);
      expect(resultado.desactualizado, isTrue);
      expect(resultado.consultado, DateTime.utc(2026, 11, 22));
      expect(llamadas, 1);
    },
  );

  test('HTTP reintenta un 503 y conserva el error permanente', () async {
    var llamadas = 0;
    final cliente = ClienteGeo(
      MockClient((_) async => http.Response('{}', ++llamadas == 1 ? 503 : 429)),
    );
    await expectLater(
      cliente.obtener(Uri.https('example.com', '/pronostico')),
      throwsA(isA<ErrorProveedor>().having((e) => e.codigo, 'estado', 429)),
    );
    expect(llamadas, 2);
  });

  test(
    'Geocodificación manual acepta resultados válidos sin permiso de GPS',
    () async {
      final repo = RepositorioGeo(
        ClienteGeo(
          MockClient((solicitud) async {
            expect(solicitud.url.queryParameters['name'], 'Carmen');
            return http.Response(
              '{"results":[{"name":"Ciudad del Carmen","admin1":"Campeche","country":"México","latitude":18.64,"longitude":-91.83},{"name":"Incompleto"}]}',
              200,
            );
          }),
        ),
      );
      expect(await repo.buscar('a'), isEmpty);
      final localidad = (await repo.buscar(' Carmen ')).single;
      expect(localidad.nombre, 'Ciudad del Carmen, Campeche, México');
      expect(localidad.coordenadas, (18.64, -91.83));
      expect(
        problemaUbicacion(false, LocationPermission.whileInUse),
        contains('Activa'),
      );
      expect(
        problemaUbicacion(true, LocationPermission.denied),
        contains('denegado'),
      );
      expect(
        problemaUbicacion(true, LocationPermission.deniedForever),
        contains('Ajustes'),
      );
      expect(problemaUbicacion(true, LocationPermission.whileInUse), isNull);
    },
  );

  test(
    'Valida coordenadas de marcadores y descarta especies no publicadas',
    () {
      final punto = {
        'latitud': 18.6,
        'longitud': -91.8,
        'puntos_especies': [
          {
            'especies': {'nombre': 'Sábalo', 'publicado': true},
          },
          {
            'especies': {'nombre': 'Oculta', 'publicado': false},
          },
          {'especies': null},
        ],
      };
      expect(coordenadaPunto(punto)!.latitude, 18.6);
      expect(coordenadaPunto({'latitud': 91, 'longitud': 0}), isNull);
      expect(especiesPunto(punto), ['Sábalo']);
    },
  );
}
