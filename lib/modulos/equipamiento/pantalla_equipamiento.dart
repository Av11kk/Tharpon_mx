import 'package:flutter/material.dart';

import '../../compartido/widgets/estado_operacion.dart';
import '../../nucleo/medidas_app.dart';

/// Pantalla de Equipo de Tarpon MX.
///
/// Este módulo contendrá:
/// - Artículos de pesca.
/// - Categorías de productos.
/// - Equipos recomendados.
/// - Promociones de la tienda.
///
/// Conservamos PantallaEquipamiento como nombre
/// interno temporal para evitar romper imports.
class PantallaEquipamiento extends StatelessWidget {
  const PantallaEquipamiento({super.key, this.mostrarPromociones = false});

  final bool mostrarPromociones;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mostrarPromociones
          ? const SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(MedidasApp.margenPantalla),
                child: PanelEstadoApp(
                  tipo: TipoEstadoOperacion.vacio,
                  mensaje:
                      'Las promociones aún no están disponibles en la app.',
                ),
              ),
            )
          : const Center(child: Text('Equipamiento Tarpon')),
    );
  }
}
