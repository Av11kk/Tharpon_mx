import 'package:flutter/material.dart';

/// =====================================================
/// COLORES CORPORATIVOS DE TARPON MX
/// =====================================================
///
/// Esta clase almacena los colores principales
/// utilizados en toda nuestra aplicación.
///
/// OBJETIVO:
/// Mantener una identidad visual consistente.
///
/// VENTAJA:
/// Si necesitamos modificar un color, solamente
/// tendremos que cambiarlo en este archivo.
///
/// Por ejemplo:
///
/// ColoresApp.azulMarino
///
/// Nos devuelve el color azul principal.
///
/// =====================================================

class ColoresApp {
  // ===================================================
  // COLORES PRINCIPALES
  // ===================================================

  /// Azul marino.
  ///
  /// Se utiliza principalmente en encabezados,
  /// botones importantes y elementos destacados.
  static const Color azulMarino = Color(0xFF0D3B66);

  /// Azul océano.
  ///
  /// Es nuestro color secundario.
  static const Color azulOceano = Color(0xFF1D70A2);

  /// Turquesa.
  ///
  /// Se utiliza para acentos visuales,
  /// indicadores y elementos seleccionados.
  static const Color turquesa = Color(0xFF00B4D8);

  // ===================================================
  // COLORES DE FONDO
  // ===================================================

  /// Color arena.
  ///
  /// Puede utilizarse en secciones especiales.
  static const Color arena = Color(0xFFF4EBD0);

  /// Color blanco.
  ///
  /// Se utiliza en tarjetas y superficies.
  static const Color blanco = Colors.white;

  /// Gris claro.
  ///
  /// Se utiliza como fondo general.
  static const Color grisClaro = Color(0xFFF4F4F4);

  // ===================================================
  // COLORES PARA TEXTOS
  // ===================================================

  /// Color oscuro para textos principales.
  static const Color textoPrincipal = Color(0xFF1F2937);

  /// Color gris para textos secundarios.
  static const Color textoSecundario = Color(0xFF616B75);
}
