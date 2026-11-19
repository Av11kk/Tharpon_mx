import 'package:flutter/material.dart';

// Colores e identificadores de Tarpon MX.
import '../../nucleo/colores_app.dart';
import '../../nucleo/modulo_app.dart';

// Importación de las pantallas existentes.
import '../inicio/pantalla_inicio.dart';
import '../especies/pantalla_especies.dart';
import '../clima/pantalla_clima.dart';
import '../mareas/pantalla_mareas.dart';
import '../mapa/pantalla_mapa.dart';
import '../equipamiento/pantalla_equipamiento.dart';
import '../consejos/pantalla_consejos.dart';
import '../perfil/pantalla_perfil.dart';

/// =====================================================
/// NAVEGACIÓN PRINCIPAL DE TARPON MX
/// =====================================================
///
/// Esta clase administra:
///
/// 1. El menú desplegable superior izquierdo.
/// 2. Los siete módulos principales.
/// 3. El botón de perfil superior derecho.
/// 4. La navegación desde los banners de Inicio.
///
/// Ya no utilizamos la barra de navegación inferior
/// ni el menú vertical flotante.

class PantallaNavegacion extends StatefulWidget {
  const PantallaNavegacion({super.key});

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  // ===================================================
  // MÓDULO ACTUAL
  // ===================================================

  /// Guarda la pantalla seleccionada.
  ///
  /// Inicialmente mostramos Inicio.
  ModuloApp moduloActual = ModuloApp.inicio;

  // ===================================================
  // DATOS DEL MENÚ
  // ===================================================

  /// Nombres que aparecerán en el menú.
  static const List<String> nombres = [
    'Inicio',
    'Especies',
    'Clima',
    'Mareas',
    'Mapa',
    'Equipo',
    'Consejos',
  ];

  /// Iconos correspondientes a las secciones.
  ///
  /// El orden coincide con ModuloApp.
  static const List<IconData> iconos = [
    Icons.home_outlined,
    Icons.phishing,
    Icons.cloud_outlined,
    Icons.waves,
    Icons.map_outlined,
    Icons.shopping_bag_outlined,
    Icons.menu_book_outlined,
  ];

  // ===================================================
  // CAMBIAR DE MÓDULO
  // ===================================================

  /// Recibe el módulo al que queremos navegar.
  ///
  /// Esta función sirve tanto para el menú
  /// como para los banners de Inicio.
  void cambiarModulo(ModuloApp nuevoModulo) {
    // Evitamos reconstrucciones innecesarias.
    if (moduloActual == nuevoModulo) {
      return;
    }

    setState(() {
      moduloActual = nuevoModulo;
    });
  }

  // ===================================================
  // ABRIR EL PERFIL
  // ===================================================

  /// Abre la pantalla del perfil mediante
  /// una nueva ruta de navegación.
  ///
  /// El usuario podrá volver a la sección
  /// en la que se encontraba anteriormente.
  void abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const PantallaPerfil()),
    );
  }

  // ===================================================
  // CONTENIDO DE LA APLICACIÓN
  // ===================================================

  /// IndexedStack conserva los widgets de las
  /// pantallas mientras cambiamos de módulo.
  ///
  /// Esto será útil cuando implementemos
  /// formularios y otras funcionalidades.
  Widget construirContenido() {
    return IndexedStack(
      index: moduloActual.index,

      children: [
        // Inicio recibe la función de navegación
        // para conectar sus cuatro banners.
        PantallaInicio(onAbrirModulo: cambiarModulo),

        const PantallaEspecies(),
        const PantallaClima(),
        const PantallaMareas(),
        const PantallaMapa(),
        const PantallaEquipamiento(),
        const PantallaConsejos(),
      ],
    );
  }

  // ===================================================
  // MENÚ DESPLEGABLE
  // ===================================================

  /// Construye el botón de tres líneas que
  /// despliega los módulos de Tarpon MX.
  Widget construirMenu() {
    return PopupMenuButton<ModuloApp>(
      // Identificador para las pruebas.
      key: const Key('boton_menu'),

      // Texto de accesibilidad.
      tooltip: 'Abrir menú',

      // Al seleccionar una opción,
      // cambiamos el módulo actual.
      onSelected: cambiarModulo,

      // Diseño del menú desplegable.
      color: ColoresApp.blanco,

      elevation: 6,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      // Generamos las siete opciones
      // utilizando nuestra enumeración.
      itemBuilder: (BuildContext context) {
        return [
          for (int i = 0; i < ModuloApp.values.length; i++)
            PopupMenuItem<ModuloApp>(
              // Identificador del módulo.
              value: ModuloApp.values[i],

              // Espacio de la opción.
              child: Row(
                children: [
                  // Icono de la sección.
                  Icon(iconos[i], color: ColoresApp.azulMarino, size: 22),

                  const SizedBox(width: 12),

                  // Nombre de la sección.
                  Text(
                    nombres[i],
                    style: const TextStyle(
                      color: ColoresApp.textoPrincipal,
                      fontSize: 14,
                    ),
                  ),

                  // Marca la sección seleccionada.
                  if (moduloActual == ModuloApp.values[i]) ...[
                    const Spacer(),

                    const Icon(
                      Icons.check,
                      color: ColoresApp.azulOceano,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
        ];
      },

      // Botón visible cuando el menú está cerrado.
      child: Container(
        width: 46,
        height: 46,

        decoration: BoxDecoration(
          color: ColoresApp.azulMarino,
          borderRadius: BorderRadius.circular(12),
        ),

        child: const Icon(Icons.menu, color: Colors.white, size: 26),
      ),
    );
  }

  // ===================================================
  // BOTÓN DE PERFIL
  // ===================================================

  /// Construye el botón que abre el perfil.
  Widget construirBotonPerfil() {
    return Material(
      color: ColoresApp.azulMarino,
      shape: const CircleBorder(),

      child: IconButton(
        key: const Key('boton_perfil'),

        tooltip: 'Abrir perfil',

        onPressed: abrirPerfil,

        icon: const Icon(Icons.person_outline, color: Colors.white),
      ),
    );
  }

  // ===================================================
  // CONSTRUCCIÓN PRINCIPAL
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===========================================
          // CONTENIDO DEL MÓDULO SELECCIONADO
          // ===========================================

          Positioned.fill(child: construirContenido()),

          // ===========================================
          // MENÚ SUPERIOR IZQUIERDO
          // ===========================================
          Positioned(
            top: 0,
            left: 12,

            // SafeArea evita la barra de estado
            // y otros espacios del sistema.
            child: SafeArea(child: construirMenu()),
          ),

          // ===========================================
          // PERFIL SUPERIOR DERECHO
          // ===========================================
          Positioned(
            top: 0,
            right: 12,

            child: SafeArea(child: construirBotonPerfil()),
          ),
        ],
      ),
    );
  }
}
