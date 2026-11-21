import 'package:flutter/material.dart';

/// Catálogo de especies de Ciudad del Carmen.
///
/// Esta pantalla será desarrollada posteriormente
/// para mostrar tarjetas individuales de peces.
class PantallaEspecies extends StatelessWidget {
  const PantallaEspecies({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phishing, size: 70),

              SizedBox(height: 20),

              Text(
                'Especies de Ciudad del Carmen',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12),

              Text(
                'Consulta información sobre las '
                'especies y sus técnicas de pesca.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
