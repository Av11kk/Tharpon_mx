import 'package:flutter/material.dart';

/// Pantalla principal del módulo Mareas.
///
/// Aquí mostraremos posteriormente:
/// - Horarios de pleamar.
/// - Horarios de bajamar.
/// - Alturas de marea, cuando estén disponibles.
/// - Información marítima de Ciudad del Carmen.
class PantallaMareas extends StatelessWidget {
  const PantallaMareas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Información de Mareas')));
  }
}
