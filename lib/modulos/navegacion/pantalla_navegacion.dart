import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
// Colores e identificadores de los módulos.
import '../../nucleo/colores_app.dart';
import '../../nucleo/modulo_app.dart';

// Pantallas de la aplicación.
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
/// Esta pantalla controla:
/// - El encabezado global.
/// - El menú desplegable superior izquierdo.
/// - El acceso al Perfil.
/// - El módulo seleccionado.
/// - La navegación desde los banners del Inicio.
///
/// Todas las secciones principales comparten
/// la misma barra superior.
class PantallaNavegacion extends StatefulWidget {
  const PantallaNavegacion({super.key, this.perfil, this.cerrarSesion});

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  /// Módulo que se muestra actualmente.
  ModuloApp moduloActual = ModuloApp.inicio;

  /// Nombres de las secciones principales.
  ///
  /// El orden debe coincidir con ModuloApp.
  static const List<String> nombres = [
    'Inicio',
    'Especies',
    'Clima',
    'Mareas',
    'Mapa',
    'Equipo',
    'Consejos',
  ];

  /// Iconos de cada módulo.
  static const List<IconData> iconos = [
    Icons.home_outlined,
    Icons.phishing,
    Icons.cloud_outlined,
    Icons.waves,
    Icons.map_outlined,
    Icons.shopping_bag_outlined,
    Icons.menu_book_outlined,
  ];

  /// Cambia el módulo visible.
  ///
  /// Esta función es utilizada por el menú
  /// desplegable y los banners del Inicio.
  void cambiarModulo(ModuloApp nuevoModulo) {
    if (nuevoModulo == moduloActual) {
      return;
    }

    setState(() {
      moduloActual = nuevoModulo;
    });
  }

  /// Abre el Perfil como una nueva pantalla.
  ///
  /// Cuando el usuario regrese, continuará
  /// en el módulo que estaba consultando.
  void abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PantallaPerfil(
          perfil: widget.perfil,
          cerrarSesion: widget.cerrarSesion,
        ),
      ),
    );
  }

  /// Construye las opciones del menú desplegable.
  ///
  /// PopupMenuItem representa una opción
  /// que el usuario puede seleccionar.
  List<PopupMenuEntry<ModuloApp>> construirOpciones() {
    return [
      for (int i = 0; i < ModuloApp.values.length; i++)
        PopupMenuItem<ModuloApp>(
          key: Key('opcion_${ModuloApp.values[i].name}'),

          // Identificador del módulo.
          value: ModuloApp.values[i],

          child: Row(
            children: [
              Icon(iconos[i], color: ColoresApp.azulMarino),

              const SizedBox(width: 12),

              Expanded(child: Text(nombres[i])),

              // Indica la opción seleccionada.
              if (moduloActual == ModuloApp.values[i])
                const Icon(Icons.check, color: ColoresApp.azulOceano, size: 18),
            ],
          ),
        ),
    ];
  }

  /// Construye el botón superior izquierdo.
  Widget construirMenu() {
    return PopupMenuButton<ModuloApp>(
      key: const Key('boton_menu'),

      tooltip: 'Abrir menú',

      // Abre el módulo seleccionado.
      onSelected: cambiarModulo,

      // Opciones que aparecerán al presionar.
      itemBuilder: (context) => construirOpciones(),

      // Estilo del menú.
      color: ColoresApp.blanco,
      elevation: 5,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      // Icono de tres líneas.
      icon: const Icon(Icons.menu),
    );
  }

  /// Construye la barra superior compartida.
  PreferredSizeWidget construirBarraSuperior() {
    return AppBar(
      // Botón desplegable superior izquierdo.
      leading: construirMenu(),

      // Nombre comercial de la aplicación.
      title: const Text('TARPON MX'),

      // Centra el nombre de la aplicación.
      centerTitle: true,

      // Botones de la esquina derecha.
      actions: [
        IconButton(
          key: const Key('boton_perfil'),

          tooltip: 'Abrir perfil',

          onPressed: abrirPerfil,

          icon: const Icon(Icons.account_circle_outlined, size: 28),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  /// Construye las siete pantallas principales.
  ///
  /// IndexedStack conserva las pantallas
  /// montadas cuando cambiamos de sección.
  ///
  /// IMPORTANTE:
  /// Las pantallas internas ya no deben
  /// construir su propia AppBar.
  Widget construirContenido() {
    return IndexedStack(
      index: moduloActual.index,

      children: [
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

  /// Construcción principal de la navegación.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Única barra superior principal.
      appBar: construirBarraSuperior(),

      // Contenido del módulo seleccionado.
      body: construirContenido(),
    );
  }
}
