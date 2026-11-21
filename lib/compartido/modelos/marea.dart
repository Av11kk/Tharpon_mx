// =====================================================
// MODELO DE MAREAS DE TARPON MX
// =====================================================
//
// Este archivo define cómo representaremos
// los eventos de las mareas.
//
// El modelo será utilizado por:
// - La pantalla de Inicio.
// - El módulo de Mareas.
//
// No consulta internet ni dibuja interfaces.
// Solo organiza la información.

/// Tipos de eventos de marea.
enum TipoMarea {
  /// Momento de marea alta.
  pleamar,

  /// Momento de marea baja.
  bajamar,
}

/// Representa un evento de marea.
///
/// Por ejemplo, un horario de pleamar
/// obtenido de un servicio de predicciones.
class Marea {
  /// Tipo de evento: pleamar o bajamar.
  final TipoMarea tipo;

  /// Fecha y hora del evento.
  final DateTime fechaHora;

  /// Altura del agua en metros.
  ///
  /// Puede ser null si la fuente
  /// no proporciona este dato.
  final double? alturaMetros;

  /// Referencia utilizada para medir la altura.
  ///
  /// Es importante porque diferentes fuentes
  /// pueden emplear distintos niveles de referencia.
  final String? referenciaAltura;

  /// Nombre del lugar consultado.
  final String ubicacion;

  /// Nombre de la fuente de información.
  final String fuente;

  /// Constructor del modelo.
  ///
  /// required indica los datos obligatorios.
  const Marea({
    required this.tipo,
    required this.fechaHora,
    required this.ubicacion,
    required this.fuente,
    this.alturaMetros,
    this.referenciaAltura,
  });

  /// Devuelve el nombre del evento
  /// en un formato fácil de mostrar.
  String get nombreTipo {
    switch (tipo) {
      case TipoMarea.pleamar:
        return 'Pleamar';

      case TipoMarea.bajamar:
        return 'Bajamar';
    }
  }

  /// Indica si el evento incluye
  /// una altura de marea conocida.
  bool get tieneAltura {
    return alturaMetros != null;
  }
}
