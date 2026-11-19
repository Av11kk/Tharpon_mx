import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';

/// =====================================================
/// TARJETA DASHBOARD
/// =====================================================
///
/// Widget reutilizable para mostrar información
/// en la pantalla principal.
///
/// Se reutiliza para:
/// - Clima
/// - Mareas
/// - Consejos
/// - Promociones
/// - Capturas
///
class TarjetaDashboard extends StatelessWidget {
  /// Icono principal
  final IconData icono;

  /// Título de la tarjeta
  final String titulo;

  /// Descripción
  final String descripcion;

  const TarjetaDashboard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: ColoresApp.blanco,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: ColoresApp.azulMarino,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(icono, size: 30, color: Colors.blue.shade800),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
