import 'package:flutter/material.dart';

// Colores corporativos de Tarpon MX.
import '../../nucleo/colores_app.dart';

/// =====================================================
/// BANNER REUTILIZABLE DE TARPON MX
/// =====================================================
///
/// Este widget representa una tarjeta interactiva.
///
/// Lo utilizaremos para mostrar:
/// - Clima.
/// - Mareas.
/// - Equipo.
/// - Mapa.
///
/// El mismo componente admite dos presentaciones:
///
/// compacto = true:
/// Tarjeta pequeña, para utilizar en una cuadrícula.
///
/// compacto = false:
/// Tarjeta horizontal de ancho completo.
///
/// Recibimos una función onTap que se ejecuta
/// cuando el usuario presiona el banner.
class BannerInicio extends StatelessWidget {
  /// Nombre principal de la tarjeta.
  final String titulo;

  /// Breve explicación de su contenido.
  final String descripcion;

  /// Icono que representa el módulo.
  final IconData icono;

  /// Función que se ejecuta al presionar.
  final VoidCallback onTap;

  /// Indica si la tarjeta será compacta.
  final bool compacto;

  /// Constructor del componente.
  const BannerInicio({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onTap,
    this.compacto = false,
  });

  /// Construye la tarjeta visual.
  @override
  Widget build(BuildContext context) {
    return Card(
      // Evita espacios adicionales alrededor.
      margin: EdgeInsets.zero,

      // Permite detectar la pulsación del usuario.
      child: InkWell(
        // Mantiene la zona pulsable redondeada.
        borderRadius: BorderRadius.circular(20),

        // Ejecuta la función recibida.
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          // Cambiamos la distribución dependiendo
          // del tipo de tarjeta.
          child: compacto
              ? construirContenidoCompacto()
              : construirContenidoHorizontal(),
        ),
      ),
    );
  }

  /// ===================================================
  /// DISEÑO COMPACTO
  /// ===================================================
  ///
  /// Se utiliza para Clima y Mareas.
  Widget construirContenidoCompacto() {
    return SizedBox(
      height: 145,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Icono principal.
          Icon(icono, color: ColoresApp.azulOceano, size: 30),

          const SizedBox(height: 10),

          // Título de la tarjeta.
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColoresApp.azulMarino,
            ),
          ),

          const SizedBox(height: 5),

          // Descripción.
          Expanded(
            child: Text(
              descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: ColoresApp.textoSecundario,
              ),
            ),
          ),

          // Flecha que indica navegación.
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_forward,
              color: ColoresApp.azulOceano,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// ===================================================
  /// DISEÑO HORIZONTAL
  /// ===================================================
  ///
  /// Se utiliza para Equipo y Mapa.
  Widget construirContenidoHorizontal() {
    return Row(
      children: [
        // Icono representativo.
        Icon(icono, color: ColoresApp.azulOceano, size: 34),

        const SizedBox(width: 16),

        // Textos de la tarjeta.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.azulMarino,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                descripcion,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Indica que podemos abrir el módulo.
        const Icon(Icons.chevron_right, color: ColoresApp.azulMarino),
      ],
    );
  }
}
