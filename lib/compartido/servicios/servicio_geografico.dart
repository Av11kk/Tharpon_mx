import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

typedef JsonGeo = Map<String, dynamic>;

class Localidad {
  const Localidad(this.nombre, this.latitud, this.longitud);
  final String nombre;
  final double latitud, longitud;
  static const carmen = Localidad('Ciudad del Carmen', 18.64592, -91.82991);
  (double, double) get coordenadas => (latitud, longitud);
}

String? problemaUbicacion(bool habilitado, LocationPermission permiso) {
  if (!habilitado) {
    return 'Activa la ubicación del dispositivo o elige una localidad manualmente.';
  }
  if (permiso == LocationPermission.deniedForever) {
    return 'Habilita el permiso en Ajustes o elige una localidad manualmente.';
  }
  if (permiso != LocationPermission.whileInUse &&
      permiso != LocationPermission.always) {
    return 'Permiso de ubicación denegado. Puedes elegir una localidad manualmente.';
  }
  return null;
}

class UbicacionManual extends ValueNotifier<Localidad> {
  UbicacionManual() : super(Localidad.carmen);

  Future<Localidad> localizar() async {
    final habilitado = await Geolocator.isLocationServiceEnabled();
    var permiso = habilitado
        ? await Geolocator.checkPermission()
        : LocationPermission.denied;
    if (habilitado && permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (problemaUbicacion(habilitado, permiso) case final error?) {
      throw FormatException(error);
    }
    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 12),
      ),
    );
    // Resolución aproximada de un kilómetro, suficiente para el pronóstico.
    double aproximar(double valor) => (valor * 100).round() / 100;
    return Localidad(
      'Ubicación aproximada',
      aproximar(posicion.latitude),
      aproximar(posicion.longitude),
    );
  }
}

class RespuestaGeo<T> {
  const RespuestaGeo(
    this.datos,
    this.consultado, {
    this.desactualizado = false,
  });
  final T datos;
  final DateTime consultado;
  final bool desactualizado;
}

class CacheGeo<K, T> {
  CacheGeo({
    this.vigencia = const Duration(minutes: 15),
    DateTime Function()? reloj,
  }) : reloj = reloj ?? DateTime.now;
  final Duration vigencia;
  final DateTime Function() reloj;
  final _datos = <K, RespuestaGeo<T>>{};
  final _pendientes = <K, Future<RespuestaGeo<T>>>{};

  Future<RespuestaGeo<T>> consultar(
    K clave,
    Future<T> Function() cargar, {
    bool renovar = false,
  }) {
    if (_pendientes[clave] case final pendiente?) return pendiente;
    final anterior = _datos[clave];
    if (!renovar &&
        anterior != null &&
        reloj().difference(anterior.consultado) < vigencia) {
      return Future.value(anterior);
    }
    return _pendientes[clave] = Future.sync(cargar)
        .then(
          (datos) {
            if (_datos.length >= 12 && !_datos.containsKey(clave)) {
              _datos.remove(_datos.keys.first);
            }
            return _datos[clave] = RespuestaGeo(datos, reloj());
          },
          onError: (Object error, StackTrace traza) {
            if (anterior != null) {
              return RespuestaGeo(
                anterior.datos,
                anterior.consultado,
                desactualizado: true,
              );
            }
            Error.throwWithStackTrace(error, traza);
          },
        )
        .whenComplete(() {
          _pendientes.remove(clave);
        });
  }
}

class ErrorProveedor implements Exception {
  const ErrorProveedor(this.codigo);
  final int codigo;
}

class ClienteGeo {
  ClienteGeo(this.httpCliente);
  final http.Client httpCliente;

  Future<JsonGeo> obtener(Uri uri) async {
    for (var intento = 0; ; intento++) {
      try {
        final respuesta = await httpCliente
            .get(uri)
            .timeout(const Duration(seconds: 10));
        if (respuesta.statusCode != 200) {
          throw ErrorProveedor(respuesta.statusCode);
        }
        final json = jsonDecode(respuesta.body);
        if (json is! JsonGeo) {
          throw const FormatException('Respuesta incompleta.');
        }
        return json;
      } on Object catch (error) {
        final transitorio =
            error is TimeoutException ||
            error is http.ClientException ||
            (error is ErrorProveedor && error.codigo >= 500);
        if (intento > 0 || !transitorio) rethrow;
      }
    }
  }
}

class SerieGeo {
  const SerieGeo(this.filas);
  final List<PasoGeo> filas;
  factory SerieGeo.desde(Object? datos) {
    if (datos is! Map) return const SerieGeo([]);
    final tiempos = datos['time'];
    if (tiempos is! List) return const SerieGeo([]);
    return SerieGeo([
      for (var i = 0; i < tiempos.length; i++)
        if (tiempos[i] is String)
          PasoGeo(tiempos[i] as String, {
            for (final entrada in datos.entries)
              if (entrada.key != 'time' &&
                  entrada.value is List &&
                  i < (entrada.value as List).length)
                entrada.key as String: (entrada.value as List)[i],
          }),
    ]);
  }
}

class PasoGeo {
  const PasoGeo(this.hora, this.campos);
  final String hora;
  final JsonGeo campos;
  double? numero(String clave) {
    final dato = campos[clave];
    return dato is num && dato.isFinite ? dato.toDouble() : null;
  }

  String? texto(String clave) =>
      campos[clave] is String ? campos[clave] as String : null;
}

class PronosticoGeo {
  PronosticoGeo.desde(JsonGeo json)
    : zona = json['timezone'] as String? ?? 'Zona horaria sin informar',
      actual = PasoGeo(
        (json['current'] as Map?)?['time']?.toString() ?? '',
        Map<String, dynamic>.from(json['current'] as Map? ?? {}),
      ),
      horas = SerieGeo.desde(json['hourly']).filas,
      dias = SerieGeo.desde(json['daily']).filas;

  final String zona;
  final PasoGeo actual;
  final List<PasoGeo> horas, dias;
  List<PasoGeo> get siguientes => horas
      .where((paso) => paso.hora.compareTo(actual.hora) >= 0)
      .take(24)
      .toList();
}

class EventoMarea {
  const EventoMarea(
    this.hora,
    this.pleamar,
    this.alturaMetros, {
    this.horaCivil,
  });
  final DateTime hora;
  final bool pleamar;
  final double? alturaMetros;
  final String? horaCivil;
}

abstract interface class ProveedorMareas {
  String get fuente;
  Future<List<EventoMarea>> extremos(Localidad zona, String fechaLocal);
}

class ProveedorMareasHttp implements ProveedorMareas {
  ProveedorMareasHttp(
    this.cliente,
    this.endpoint, {
    this.fuente = 'Proveedor de mareas configurado',
  });
  final ClienteGeo cliente;
  final Uri endpoint;

  @override
  final String fuente;

  @override
  Future<List<EventoMarea>> extremos(Localidad zona, String fechaLocal) async {
    final respuesta = await cliente.obtener(
      endpoint.replace(
        queryParameters: {
          'latitude': zona.latitud.toString(),
          'longitude': zona.longitud.toString(),
          'date': fechaLocal,
        },
      ),
    );
    final filas = respuesta['eventos'];
    if (filas is! List) throw const FormatException('Predicción incompleta.');
    return [
      for (final fila in filas)
        if (fila case {
          'hora': final String hora,
          'pleamar': final bool pleamar,
        })
          if (RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(hora))
            if (DateTime.tryParse(hora) case final instante?)
              EventoMarea(
                instante.toUtc(),
                pleamar,
                fila['altura_m'] is num
                    ? (fila['altura_m'] as num).toDouble()
                    : null,
                horaCivil: hora,
              ),
    ]..sort((a, b) => a.hora.compareTo(b.hora));
  }
}

class RepositorioGeo {
  RepositorioGeo(this.cliente, {this.mareas, this.pasarela});
  final ClienteGeo cliente;
  final ProveedorMareas? mareas;
  final Uri? pasarela;
  final _clima = CacheGeo<(double, double), PronosticoGeo>();
  final _mar = CacheGeo<(double, double), PronosticoGeo>();
  final _localidades = CacheGeo<String, List<Localidad>>();

  static const variablesActuales =
      'temperature_2m,apparent_temperature,is_day,weather_code,'
      'relative_humidity_2m,surface_pressure,cloud_cover,precipitation,wind_speed_10m,'
      'wind_direction_10m,wind_gusts_10m';
  static const variablesHora =
      'temperature_2m,is_day,weather_code,visibility,precipitation_probability,precipitation,uv_index,wind_speed_10m';
  static const variablesDia =
      'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_probability_max';
  static const variablesMar = 'wave_height,wave_direction,wave_period';

  Uri _uri(String host, String ruta, Map<String, String> consulta) {
    if (pasarela case final base?) {
      final prefijo = base.path.replaceFirst(RegExp(r'/$'), '');
      return base.replace(path: '$prefijo$ruta', queryParameters: consulta);
    }
    if (kReleaseMode) {
      throw const FormatException(
        'Configura el proveedor geográfico para producción.',
      );
    }
    return Uri.https(host, ruta, consulta);
  }

  Future<RespuestaGeo<PronosticoGeo>> clima(
    Localidad localidad, {
    bool renovar = false,
  }) => _clima.consultar(
    localidad.coordenadas,
    () => _pronostico(localidad, 'api.open-meteo.com', '/v1/forecast', {
      'current': variablesActuales,
      'hourly': variablesHora,
      'daily': variablesDia,
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'precipitation_unit': 'mm',
    }),
    renovar: renovar,
  );

  Future<RespuestaGeo<PronosticoGeo>> mar(
    Localidad localidad, {
    bool renovar = false,
  }) => _mar.consultar(
    localidad.coordenadas,
    () => _pronostico(localidad, 'marine-api.open-meteo.com', '/v1/marine', {
      'current': variablesMar,
      'hourly': '$variablesMar,sea_level_height_msl',
    }),
    renovar: renovar,
  );

  Future<PronosticoGeo> _pronostico(
    Localidad localidad,
    String host,
    String ruta,
    Map<String, String> variables,
  ) async {
    final datos = await cliente.obtener(
      _uri(host, ruta, {
        'latitude': localidad.latitud.toString(),
        'longitude': localidad.longitud.toString(),
        'timezone': 'auto',
        'forecast_days': '7',
        ...variables,
      }),
    );
    final pronostico = PronosticoGeo.desde(datos);
    if (pronostico.actual.hora.isEmpty &&
        pronostico.horas.isEmpty &&
        pronostico.dias.isEmpty) {
      throw const FormatException('El proveedor no devolvió un pronóstico.');
    }
    return pronostico;
  }

  Future<List<Localidad>> buscar(String nombre) async {
    final consulta = nombre.trim();
    if (consulta.length < 2) return [];
    final resultado = await _localidades.consultar(
      consulta.toLowerCase(),
      () async {
        final json = await cliente.obtener(
          _uri('geocoding-api.open-meteo.com', '/v1/search', {
            'name': consulta,
            'count': '12',
            'language': 'es',
          }),
        );
        return [
          for (final fila in json['results'] as List? ?? [])
            if (fila is Map &&
                fila['name'] is String &&
                fila['latitude'] is num &&
                fila['longitude'] is num)
              Localidad(
                [
                  fila['name'],
                  fila['admin1'],
                  fila['country'],
                ].whereType<String>().toSet().join(', '),
                (fila['latitude'] as num).toDouble(),
                (fila['longitude'] as num).toDouble(),
              ),
        ];
      },
    );
    return resultado.datos;
  }
}

String rumboViento(double? valor) {
  if (valor == null || !valor.isFinite) return '—';
  const rumbos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
  return rumbos[((valor % 360) / 45).round() % 8];
}

String medidaGeo(double? dato, String unidad, {int decimales = 0}) =>
    dato == null ? '—' : '${dato.toStringAsFixed(decimales)}$unidad';

String horaGeo(String iso) => iso.length >= 16 ? iso.substring(11, 16) : '—';
String diaGeo(String iso) => iso.length >= 10 ? iso.substring(0, 10) : '—';

String condicionGeo(double? codigo) => switch (codigo?.toInt()) {
  0 => 'Despejado',
  1 => 'Mayormente despejado',
  2 => 'Parcialmente nublado',
  3 => 'Nublado',
  45 || 48 => 'Niebla',
  51 || 53 || 55 || 56 || 57 => 'Llovizna',
  61 || 63 || 65 || 66 || 67 => 'Lluvia',
  71 || 73 || 75 || 77 || 85 || 86 => 'Nieve',
  80 || 81 || 82 => 'Chubascos',
  95 || 96 || 99 => 'Tormenta',
  _ => 'Condición sin datos',
};
