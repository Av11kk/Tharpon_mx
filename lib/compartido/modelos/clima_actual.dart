// =====================================================
// MODELO DE INFORMACIÓN DEL CLIMA - TARPON MX
// =====================================================
//
// Este archivo representa las condiciones
// meteorológicas de una ubicación.
//
// RESPONSABILIDADES:
//
// 1. Almacenar la temperatura.
// 2. Almacenar la velocidad del viento.
// 3. Guardar la descripción meteorológica.
// 4. Registrar la fecha de actualización.
//
// Este modelo NO consulta internet.
// Tampoco muestra elementos visuales.
//
// Su función es organizar los datos que
// utilizarán Inicio y el módulo Clima.
// =====================================================

/// Representa las condiciones meteorológicas
/// correspondientes a una ubicación.
class ClimaActual {
  /// Nombre de la ubicación consultada.
  final String ubicacion;

  /// Temperatura expresada en grados Celsius.
  final double temperatura;

  /// Velocidad del viento en kilómetros por hora.
  final double velocidadViento;

  /// Descripción de las condiciones actuales.
  ///
  /// Por ejemplo: Soleado, Nublado o Lluvioso.
  final String descripcion;

  /// Fecha y hora a la que corresponden los datos.
  final DateTime fechaActualizacion;

  /// Constructor del modelo.
  ///
  /// `required` indica que todos los parámetros
  /// son obligatorios al crear el objeto.
  const ClimaActual({
    required this.ubicacion,
    required this.temperatura,
    required this.velocidadViento,
    required this.descripcion,
    required this.fechaActualizacion,
  });
}
