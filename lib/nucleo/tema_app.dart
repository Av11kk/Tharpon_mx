import 'package:flutter/material.dart';

// Importamos los colores oficiales de Tarpon MX.
import 'colores_app.dart';

/// =====================================================
/// TEMA GLOBAL DE TARPON MX
/// =====================================================
///
/// Esta clase configura la apariencia general
/// de nuestra aplicación.
///
/// Aquí definimos:
///
/// 1. Los colores principales.
/// 2. El fondo de las pantallas.
/// 3. Las barras superiores.
/// 4. Las tarjetas.
/// 5. Los botones.
/// 6. El menú de navegación inferior.
/// 7. Los estilos de texto.
///
/// VENTAJA:
/// Al centralizar los estilos, podemos modificar
/// la apariencia de varias pantallas desde un
/// único archivo.
/// =====================================================

class TemaApp {
  /// Tema claro utilizado por la aplicación.
  ///
  /// Se accede mediante:
  ///
  /// TemaApp.temaClaro
  static final ThemeData temaClaro = ThemeData(
    // =================================================
    // CONFIGURACIÓN DE MATERIAL DESIGN
    // =================================================

    // Activa Material Design 3.
    useMaterial3: true,

    // =================================================
    // COLORES GENERALES
    // =================================================

    // Genera un esquema de colores a partir
    // del azul marino oficial de Tarpon MX.
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColoresApp.azulMarino,
      brightness: Brightness.light,
    ),

    // Define el fondo general de las pantallas.
    scaffoldBackgroundColor: ColoresApp.grisClaro,

    // =================================================
    // BARRA SUPERIOR DE LA APLICACIÓN
    // =================================================
    appBarTheme: const AppBarTheme(
      // Color de fondo de la barra.
      backgroundColor: ColoresApp.azulMarino,

      // Color de los iconos y botones.
      foregroundColor: ColoresApp.blanco,

      // Centra el título de la barra.
      centerTitle: true,

      // Elimina la sombra.
      elevation: 0,

      // Define el estilo del título.
      titleTextStyle: TextStyle(
        color: ColoresApp.blanco,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // =================================================
    // TARJETAS
    // =================================================
    cardTheme: CardThemeData(
      // Color de fondo de las tarjetas.
      color: ColoresApp.blanco,

      // Proporciona una sombra suave.
      elevation: 3,

      // Define las esquinas redondeadas.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // =================================================
    // BOTONES ELEVADOS
    // =================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      // Define el estilo predeterminado
      // de los botones ElevatedButton.
      style: ElevatedButton.styleFrom(
        // Fondo del botón.
        backgroundColor: ColoresApp.azulMarino,

        // Color del texto e iconos.
        foregroundColor: ColoresApp.blanco,

        // Espaciado interior del botón.
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

        // Esquinas redondeadas.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // =================================================
    // MENÚ DE NAVEGACIÓN INFERIOR
    // =================================================
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      // Color de fondo del menú.
      backgroundColor: ColoresApp.blanco,

      // Color del icono seleccionado.
      selectedItemColor: ColoresApp.azulMarino,

      // Color de los iconos no seleccionados.
      unselectedItemColor: ColoresApp.textoSecundario,

      // Estilo del texto seleccionado.
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),

      // Estilo de los textos no seleccionados.
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),

      // Muestra el texto de la opción seleccionada.
      showSelectedLabels: true,

      // Muestra el texto de las demás opciones.
      showUnselectedLabels: true,

      // Mantiene visibles todas las opciones.
      // Es útil porque tenemos cinco módulos.
      type: BottomNavigationBarType.fixed,

      // Elimina la elevación.
      elevation: 0,
    ),

    // =================================================
    // ESTILOS GENERALES DE TEXTO
    // =================================================
    textTheme: const TextTheme(
      // Títulos principales.
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: ColoresApp.textoPrincipal,
      ),

      // Títulos secundarios.
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColoresApp.textoPrincipal,
      ),

      // Texto normal.
      bodyMedium: TextStyle(fontSize: 14, color: ColoresApp.textoPrincipal),

      // Texto pequeño o descriptivo.
      bodySmall: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario),
    ),
  );
}
