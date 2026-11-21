import 'dart:convert';

import 'package:http/http.dart' as http;

// Modelo que representa los datos del clima.
import '../modelos/clima_actual.dart';

// =====================================================
// SERVICIO METEOROLÓGICO DE TARPON MX
// =====================================================
//
// Responsabilidades:
//
// 1. Consultar la API Open-Meteo.
// 2. Recibir información en formato JSON.
// 3. Convertir la respuesta a ClimaActual.
// 4. Detectar errores de conexión.
// 5. Compartir la misma consulta entre pantallas.
//
// Este archivo NO construye interfaces gráficas.

class ServicioClima {
  // ===================================================
  // INSTANCIA COMPARTIDA
  // ===================================================

  /// Permite que toda la aplicación utilice
  /// el mismo servicio y la misma consulta.
  static final ServicioClima instancia = ServicioClima._();

  /// Constructor privado.
  ServicioClima._();

  // ===================================================
  // CONFIGURACIÓN GEOGRÁFICA
  // ===================================================

  /// Coordenadas aproximadas de Ciudad del Carmen.
  static const double latitud = 18.64592;
  static const double longitud = -91.82991;

  /// Guarda una consulta para reutilizarla.
  Future<ClimaActual>? _consultaActual;

  /// Momento en que comenzamos la consulta.
  DateTime? _horaConsulta;

  /// Tiempo de validez de nuestra caché.
  static const Duration duracionCache = Duration(minutes: 15);

  // ===================================================
  // OBTENER INFORMACIÓN DEL CLIMA
  // ===================================================

  /// Obtiene las condiciones meteorológicas.
  ///
  /// Si ya consultamos recientemente la API,
  /// reutilizamos la misma información.
  ///
  /// Así evitamos que Inicio y Clima soliciten
  /// los mismos datos repetidamente.
  Future<ClimaActual> obtenerClima() {
    final ahora = DateTime.now();

    // Comprobamos si tenemos una consulta reciente.
    if (_consultaActual != null &&
        _horaConsulta != null &&
        ahora.difference(_horaConsulta!) < duracionCache) {
      return _consultaActual!;
    }

    // Guardamos cuándo comenzó la nueva consulta.
    _horaConsulta = ahora;

    // Ejecutamos la consulta y guardamos su Future.
    _consultaActual = _obtenerConRecuperacion();

    return _consultaActual!;
  }

  /// Permite solicitar información nuevamente.
  ///
  /// Podremos utilizarlo más adelante en
  /// un botón de actualización.
  Future<ClimaActual> actualizarClima() {
    _consultaActual = null;
    _horaConsulta = null;

    return obtenerClima();
  }

  /// Si una consulta falla, eliminamos su caché
  /// para permitir otro intento posteriormente.
  Future<ClimaActual> _obtenerConRecuperacion() async {
    try {
      return await _descargarClima();
    } catch (_) {
      _consultaActual = null;
      _horaConsulta = null;
      rethrow;
    }
  }

  // ===================================================
  // CONSULTA HTTP
  // ===================================================

  Future<ClimaActual> _descargarClima() async {
    // Construimos la URL de forma segura.
    //
    // timezone=UTC permite interpretar
    // correctamente la fecha de respuesta.
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitud.toString(),
      'longitude': longitud.toString(),
      'current': 'temperature_2m,wind_speed_10m,weather_code',
      'timezone': 'UTC',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
    });

    // Enviamos la solicitud al servidor.
    //
    // timeout impide que una conexión lenta
    // deje la aplicación esperando indefinidamente.
    final respuesta = await http.get(uri).timeout(const Duration(seconds: 15));

    // Un código 200 indica que la solicitud
    // HTTP se completó correctamente.
    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar el clima: '
        '${respuesta.statusCode}',
      );
    }

    // Convertimos el texto JSON a un mapa Dart.
    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    // Extraemos las condiciones actuales.
    final actual = datos['current'] as Map<String, dynamic>;

    // Obtenemos los valores numéricos.
    final temperatura = (actual['temperature_2m'] as num).toDouble();

    final viento = (actual['wind_speed_10m'] as num).toDouble();

    final codigo = (actual['weather_code'] as num).toInt();

    // La API devuelve una hora UTC sin Z
    // cuando se utiliza el formato ISO.
    //
    // Añadimos Z para interpretarla como UTC.
    final fecha = DateTime.parse('${actual['time']}Z').toLocal();

    // Creamos un objeto con los datos procesados.
    return ClimaActual(
      ubicacion: 'Ciudad del Carmen, Campeche',
      temperatura: temperatura,
      velocidadViento: viento,
      descripcion: describirClima(codigo),
      fechaActualizacion: fecha,
    );
  }

  // ===================================================
  // INTERPRETAR EL CÓDIGO METEOROLÓGICO
  // ===================================================

  /// Traduce los códigos meteorológicos
  /// utilizados por la API a textos en español.
  String describirClima(int codigo) {
    switch (codigo) {
      case 0:
        return 'Despejado';

      case 1:
        return 'Mayormente despejado';

      case 2:
        return 'Parcialmente nublado';

      case 3:
        return 'Nublado';

      case 45:
      case 48:
        return 'Niebla';

      case 51:
      case 53:
      case 55:
        return 'Llovizna';

      case 61:
      case 63:
      case 65:
        return 'Lluvia';

      case 80:
      case 81:
      case 82:
        return 'Chubascos';

      case 95:
      case 96:
      case 99:
        return 'Tormenta eléctrica';

      default:
        return 'Condición meteorológica '
            'no especificada';
    }
  }
}
