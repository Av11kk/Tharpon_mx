/// ======================================================
/// MODELO CONSEJO
/// ======================================================
///
/// Representa un artículo o consejo de pesca.
///
/// Ejemplos:
/// - Cómo pescar robalo
/// - Técnicas de surf fishing
/// - Tipos de señuelos
///
class Consejo {
  /// Título del consejo.
  final String titulo;

  /// Descripción corta.
  final String descripcion;

  /// Contenido completo.
  final String contenido;

  const Consejo({
    required this.titulo,
    required this.descripcion,
    required this.contenido,
  });
}
