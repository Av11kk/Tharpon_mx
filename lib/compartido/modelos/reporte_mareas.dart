import 'marea.dart';

/// =====================================================
/// REPORTE DE MAREAS DE TARPON MX
/// =====================================================
///
/// Agrupa los eventos de marea correspondientes
/// a una consulta.
///
/// Podrá compartirse entre el módulo Mareas
/// y el banner de Mareas de Inicio.
class ReporteMareas {
  /// Lugar al que corresponde la información.
  final String ubicacion;

  /// Momento en que obtuvimos los datos.
  final DateTime fechaConsulta;

  /// Lista de eventos disponibles.
  final List<Marea> eventos;

  /// Constructor del reporte.
  const ReporteMareas({
    required this.ubicacion,
    required this.fechaConsulta,
    required this.eventos,
  });

  /// Obtiene el próximo evento de marea
  /// posterior a la fecha proporcionada.
  ///
  /// Si no hay eventos futuros, devuelve null.
  Marea? proximaMarea(DateTime ahora) {
    Marea? siguiente;

    // Revisamos todos los eventos disponibles.
    for (final evento in eventos) {
      // Ignoramos los eventos que ya pasaron.
      if (!evento.fechaHora.isAfter(ahora)) {
        continue;
      }

      // Guardamos el evento más próximo.
      if (siguiente == null || evento.fechaHora.isBefore(siguiente.fechaHora)) {
        siguiente = evento;
      }
    }

    return siguiente;
  }
}
