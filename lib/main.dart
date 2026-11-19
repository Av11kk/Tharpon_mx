import 'package:flutter/material.dart';

// Importamos la configuración visual de THARPOM MX.
// Aquí se definen los colores y estilos generales.
import 'nucleo/tema_app.dart';

// Importamos la pantalla que administra
// el menú de navegación principal.
import 'modulos/navegacion/pantalla_navegacion.dart';

/// =====================================================
/// PUNTO DE ENTRADA DE THARPOM MX
/// =====================================================
///
/// La función main() es la primera que se ejecuta
/// cuando se inicia nuestra aplicación.
///
/// Desde aquí le indicamos a Flutter cuál es
/// el widget principal que debe mostrar.
void main() {
  // runApp() inicia la interfaz gráfica de Flutter.
  //
  // TharpomMX es nuestra clase principal.
  //
  // Utilizamos const porque este widget puede
  // construirse con una configuración constante.
  runApp(const TharpomMX());
}

/// =====================================================
/// CLASE PRINCIPAL DE THARPOM MX
/// =====================================================
///
/// Esta clase representa la raíz de la aplicación.
///
/// Hereda de StatelessWidget porque no necesita
/// administrar un estado interno que cambie.
///
/// Su responsabilidad es configurar:
///
/// 1. La aplicación Material.
/// 2. El tema visual.
/// 3. La pantalla inicial.
/// 4. Las opciones generales de presentación.
class TharpomMX extends StatelessWidget {
  // Constructor de nuestra clase principal.
  //
  // super.key permite identificar este widget
  // dentro del árbol de widgets de Flutter.
  const TharpomMX({super.key});

  /// Método encargado de construir la interfaz
  /// correspondiente a este widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp proporciona la configuración
    // principal de una aplicación Material Design.
    return MaterialApp(
      // Oculta la etiqueta DEBUG que aparece
      // durante el desarrollo.
      debugShowCheckedModeBanner: false,

      // Aplica el tema visual definido
      // en nuestro archivo tema_app.dart.
      theme: TemaApp.temaClaro,

      // Define la primera pantalla de la app.
      //
      // PantallaNavegacion administra las
      // diferentes secciones mediante
      // el menú inferior.
      home: const PantallaNavegacion(),
    );
  }
}
