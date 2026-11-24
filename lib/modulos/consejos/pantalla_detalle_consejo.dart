import 'package:flutter/material.dart';

import '../../compartido/modelos/consejo.dart';

class PantallaDetalleConsejo extends StatelessWidget {
  final Consejo consejo;

  const PantallaDetalleConsejo({super.key, required this.consejo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(consejo.titulo)),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Text(consejo.contenido, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
