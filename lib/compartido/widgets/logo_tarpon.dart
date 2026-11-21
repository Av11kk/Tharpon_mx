import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar el logotipo
/// oficial de la aplicación Tarpon MX.
///
/// Podemos utilizarlo en diferentes pantallas
/// sin tener que repetir el código.
class LogoTarpon extends StatelessWidget {
  /// Ancho del logotipo.
  final double ancho;

  /// Alto del logotipo.
  final double alto;

  /// Constructor del widget.
  ///
  /// Si no indicamos las dimensiones,
  /// se utilizan los valores predeterminados.
  const LogoTarpon({super.key, this.ancho = 220, this.alto = 160});

  /// Construye la interfaz del logotipo.
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      // Ubicación del archivo PNG.
      'assets/logos/logo_tarpon.png',

      // Dimensiones configurables.
      width: ancho,
      height: alto,

      // Evita que la imagen se deforme.
      fit: BoxFit.contain,

      // Muestra un indicador si no se puede
      // cargar la imagen.
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        );
      },
    );
  }
}
