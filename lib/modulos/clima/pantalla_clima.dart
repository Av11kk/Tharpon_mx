import 'package:flutter/material.dart';

// Modelo de los datos meteorológicos.
import '../../compartido/modelos/clima_actual.dart';

// Servicio que consulta Open-Meteo.
import '../../compartido/servicios/servicio_clima.dart';

// Colores corporativos.
import '../../nucleo/colores_app.dart';

/// =====================================================
/// PANTALLA DE CLIMA DE TARPON MX
/// =====================================================
///
/// Muestra información meteorológica real
/// correspondiente a Ciudad del Carmen.
///
/// Estados de la pantalla:
///
/// 1. Cargando información.
/// 2. Datos obtenidos correctamente.
/// 3. Error al consultar el servicio.
///
/// Utilizamos StatefulWidget para administrar
/// la consulta y permitir actualizarla.
class PantallaClima extends StatefulWidget {
  const PantallaClima({super.key});

  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  /// Guarda la operación que obtiene el clima.
  late Future<ClimaActual> _consulta;

  @override
  void initState() {
    super.initState();

    // Obtenemos los datos al crear la pantalla.
    _consulta = ServicioClima.instancia.obtenerClima();
  }

  /// Actualiza la información al presionar
  /// el botón de recarga.
  void actualizar() {
    setState(() {
      _consulta = ServicioClima.instancia.actualizarClima();
    });
  }

  /// Construye una tarjeta con información.
  Widget construirDato({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icono, color: ColoresApp.etiqueta, size: 30),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo),

                  const SizedBox(height: 5),

                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la pantalla.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ClimaActual>(
        future: _consulta,

        builder: (context, snapshot) {
          // ==========================================
          // ESTADO: CARGANDO
          // ==========================================

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================================
          // ESTADO: ERROR
          // ==========================================

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 60),

                    const SizedBox(height: 16),

                    const Text(
                      'No se pudo consultar el clima.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: actualizar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==========================================
          // ESTADO: DATOS DISPONIBLES
          // ==========================================

          final clima = snapshot.data!;

          final hora =
              '${clima.fechaActualizacion.hour.toString().padLeft(2, '0')}:'
              '${clima.fechaActualizacion.minute.toString().padLeft(2, '0')}';

          return ListView(
            padding: const EdgeInsets.all(16),

            children: [
              const SizedBox(height: 8),

              const Text(
                'Clima en Ciudad del Carmen',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              construirDato(
                icono: Icons.thermostat,
                titulo: 'Temperatura',
                valor: '${clima.temperatura.toStringAsFixed(1)} °C',
              ),

              construirDato(
                icono: Icons.air,
                titulo: 'Viento',
                valor: '${clima.velocidadViento.toStringAsFixed(1)} km/h',
              ),

              construirDato(
                icono: Icons.cloud_outlined,
                titulo: 'Condiciones',
                valor: clima.descripcion,
              ),

              const SizedBox(height: 12),

              Text(
                'Hora del dato: $hora '
                '(hora local del dispositivo)',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: actualizar,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar clima'),
              ),

              const SizedBox(height: 16),

              const Text(
                'Fuente: Open-Meteo. Información '
                'meteorológica de referencia; '
                'no sustituye los avisos oficiales '
                'para navegación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textoSecundario,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
