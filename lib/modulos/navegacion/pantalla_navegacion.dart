import 'package:flutter/material.dart';

import '../inicio/pantalla_inicio.dart';
import '../capturas/pantalla_capturas.dart';
import '../mapa/pantalla_mapa.dart';
import '../equipamiento/pantalla_equipamiento.dart';
import '../perfil/pantalla_perfil.dart';

/// Pantalla principal de navegación.
///
/// Controla el menú inferior de TARPON MX.
class PantallaNavegacion extends StatefulWidget {
  const PantallaNavegacion({super.key});

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  /// Índice de la pantalla seleccionada.
  int indiceActual = 0;

  /// Lista de pantallas disponibles.
  final List<Widget> pantallas = [
    const PantallaInicio(),
    const PantallaCapturas(),
    const PantallaMapa(),
    const PantallaEquipamiento(),
    const PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pantallas[indiceActual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceActual,

        onTap: (index) {
          setState(() {
            indiceActual = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.phishing),
            label: 'Capturas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Equipamiento',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
