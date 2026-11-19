import 'package:flutter/material.dart';

import 'colores_app.dart';

/// =====================================================
/// TEMA GLOBAL DE TARPON MX
/// =====================================================
///
/// Aquí se configura la apariencia general
/// de toda la aplicación.
///
/// Ventaja:
/// Cambios globales desde un solo lugar.
///
class TemaApp {
  static ThemeData temaClaro = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: ColoresApp.grisClaro,

    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresApp.azulMarino,
      foregroundColor: ColoresApp.blanco,
      centerTitle: true,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: ColoresApp.blanco,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    colorScheme: ColorScheme.fromSeed(seedColor: ColoresApp.azulMarino),
  );
}
