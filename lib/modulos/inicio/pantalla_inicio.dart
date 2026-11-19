import 'package:flutter/material.dart';

// Identificadores de nuestros módulos.
import '../../nucleo/modulo_app.dart';

// Componentes visuales reutilizables.
import '../../compartido/widgets/logo_tarpon.dart';
import '../../compartido/widgets/banner_inicio.dart';

/// =====================================================
/// PANTALLA PRINCIPAL DE TARPON MX
/// =====================================================
///
/// Esta pantalla muestra únicamente:
///
/// 1. Logotipo oficial.
/// 2. Banner de Clima.
/// 3. Banner de Mareas.
/// 4. Banner de Equipo.
/// 5. Banner de Mapa.
///
/// Los banners permiten navegar a sus módulos.
///
/// No creamos AppBar porque la barra superior
/// pertenece a PantallaNavegacion.
class PantallaInicio extends StatelessWidget {
  /// Función utilizada para abrir un módulo.
  final ValueChanged<ModuloApp> onAbrirModulo;

  /// Constructor de nuestra pantalla.
  const PantallaInicio({super.key, required this.onAbrirModulo});

  /// Construye la interfaz principal.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permite desplazar el contenido cuando
      // la pantalla del teléfono es pequeña.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              // =====================================
              // LOGOTIPO OFICIAL
              // =====================================

              const Center(child: LogoTarpon(ancho: 240, alto: 165)),

              const SizedBox(height: 20),

              // =====================================
              // CLIMA Y MAREAS
              // =====================================

              // Row coloca dos tarjetas
              // horizontalmente.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // CLIMA
                  Expanded(
                    child: BannerInicio(
                      key: const Key('banner_clima'),

                      titulo: 'Clima',

                      descripcion:
                          'Condiciones meteorológicas '
                          'de Ciudad del Carmen.',

                      icono: Icons.cloud_outlined,

                      compacto: true,

                      onTap: () {
                        onAbrirModulo(ModuloApp.clima);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // MAREAS
                  Expanded(
                    child: BannerInicio(
                      key: const Key('banner_mareas'),

                      titulo: 'Mareas',

                      descripcion: 'Consulta pleamar y bajamar.',

                      icono: Icons.waves,

                      compacto: true,

                      onTap: () {
                        onAbrirModulo(ModuloApp.mareas);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =====================================
              // EQUIPO DE LA TIENDA
              // =====================================
              BannerInicio(
                key: const Key('banner_equipo'),

                titulo: 'Equipo de la tienda',

                descripcion:
                    'Descubre artículos de pesca '
                    'y promociones de Tarpon MX.',

                icono: Icons.shopping_bag_outlined,

                onTap: () {
                  onAbrirModulo(ModuloApp.equipo);
                },
              ),

              const SizedBox(height: 16),

              // =====================================
              // MAPA DE PESCA
              // =====================================
              BannerInicio(
                key: const Key('banner_mapa'),

                titulo: 'Mapa de pesca',

                descripcion:
                    'Explora los puntos de pesca '
                    'de Ciudad del Carmen.',

                icono: Icons.map_outlined,

                onTap: () {
                  onAbrirModulo(ModuloApp.mapa);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
