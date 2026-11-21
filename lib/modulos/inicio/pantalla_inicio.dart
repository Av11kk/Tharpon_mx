import 'package:flutter/material.dart';

// Identificadores de nuestros módulos.
import '../../nucleo/modulo_app.dart';

// Componentes visuales reutilizables.
import '../../compartido/widgets/logo_tarpon.dart';
import '../../compartido/widgets/banner_inicio.dart';
import '../../compartido/modelos/clima_actual.dart';
import '../../compartido/servicios/servicio_clima.dart';

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
                    child: FutureBuilder<ClimaActual>(
                      // Utilizamos el mismo servicio que PantallaClima.
                      future: ServicioClima.instancia.obtenerClima(),

                      builder: (context, snapshot) {
                        // Texto mostrado mientras se descargan datos.
                        String descripcion = 'Consultando clima...';

                        // Si recibimos información correcta,
                        // mostramos temperatura y viento.
                        if (snapshot.hasData) {
                          final clima = snapshot.data!;

                          descripcion =
                              '${clima.temperatura.toStringAsFixed(1)} °C\n'
                              'Viento: '
                              '${clima.velocidadViento.toStringAsFixed(0)} km/h';
                        }

                        // Si la consulta falla, no mostramos
                        // información inventada.
                        if (snapshot.hasError) {
                          descripcion = 'Información no disponible';
                        }

                        // Mostramos el banner interactivo.
                        return BannerInicio(
                          key: const Key('banner_clima'),

                          titulo: 'Clima',
                          descripcion: descripcion,
                          icono: Icons.cloud_outlined,
                          compacto: true,

                          // Abre el módulo completo de Clima.
                          onTap: () {
                            onAbrirModulo(ModuloApp.clima);
                          },
                        );
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
