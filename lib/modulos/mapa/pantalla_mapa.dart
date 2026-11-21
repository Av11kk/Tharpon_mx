import 'package:flutter/material.dart';

/// Pantalla del mapa de pesca.
///
/// Posteriormente tendrá un mapa interactivo
/// de Ciudad del Carmen con marcadores
/// para los puntos de pesca conocidos.
class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Mapa de Zonas de Pesca')));
  }
}
