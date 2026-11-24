// =====================================================
// MÓDULOS PRINCIPALES DE TARPON MX
// =====================================================
//
// Este archivo contiene los identificadores
// de los módulos principales de la aplicación.
//
// Utilizamos enum para definir un conjunto fijo
// de opciones.
//
// Esto permite identificar las pantallas
// mediante nombres en lugar de números.
//
// Por ejemplo:
//
// ModuloApp.clima
//
// Representa el módulo del clima.
//
// =====================================================

/// Enumeración de los módulos principales.
///
/// Cada elemento identifica una pantalla
/// dentro del sistema de navegación.
enum ModuloApp {
  /// Pantalla principal y banners informativos.
  inicio,

  /// Catálogo de especies de Ciudad del Carmen.
  especies,

  /// Información meteorológica.
  clima,

  /// Horarios y movimientos de las mareas.
  mareas,

  /// Mapa de puntos de pesca.
  mapa,

  /// Equipamiento, productos y promociones.
  equipo,

  /// Consejos generales de pesca.
  consejos,
}
