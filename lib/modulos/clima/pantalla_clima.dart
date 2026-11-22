import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_geografico.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/panel_geografico.dart';

class PantallaClima extends StatelessWidget {
  const PantallaClima({super.key, required this.entorno});
  final EntornoGeo entorno;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: entorno.localidad,
    builder: (context, sitio, _) => ListaCliente(
      children: [
        EncabezadoApp(
          titulo: 'Clima',
          descripcion: sitio.nombre,
          destacado: true,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            BotonSecundario(
              texto: 'Elegir localidad',
              alPulsar: () async {
                final seleccion = await elegirLocalidad(context, entorno);
                if (context.mounted && seleccion != null) {
                  entorno.localidad.value = seleccion;
                }
              },
            ),
            IconButton(
              tooltip: 'Actualizar clima',
              onPressed: entorno.actualizarClima,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        ConsultaGeo(
          consulta: entorno.clima,
          recargar: entorno.actualizarClima,
          builder: (datos) => _Pronostico(datos: datos),
        ),
      ],
    ),
  );
}

class _Pronostico extends StatelessWidget {
  const _Pronostico({required this.datos});
  final RespuestaGeo<PronosticoGeo> datos;

  @override
  Widget build(BuildContext context) {
    final pronostico = datos.datos;
    final actual = pronostico.actual;
    final hoy = pronostico.dias.firstOrNull;
    final proxima = pronostico.siguientes.firstOrNull;
    final texto = Theme.of(context).textTheme;
    String valor(String c, String u, {int decimales = 0}) =>
        medidaGeo(actual.numero(c), u, decimales: decimales);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        TarjetaApp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                condicionGeo(actual.numero('weather_code')),
                style: texto.bodyMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      valor('temperature_2m', ' °C'),
                      style: texto.displaySmall,
                    ),
                  ),
                  Icon(_icono(actual), size: 44),
                ],
              ),
              Text('Sensación ${valor('apparent_temperature', ' °C')}'),
              Text(
                'Máx. ${medidaGeo(hoy?.numero('temperature_2m_max'), ' °C')} · Mín. ${medidaGeo(hoy?.numero('temperature_2m_min'), ' °C')}',
              ),
              Text(
                'Modelo: ${horaGeo(actual.hora)} · ${pronostico.zona}',
                style: texto.bodySmall,
              ),
            ],
          ),
        ),
        TarjetaApp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text('Próximas horas', style: texto.titleMedium),
              if (pronostico.siguientes.isEmpty)
                const Text('Sin pronóstico por hora'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 14,
                  children: [
                    for (final paso in pronostico.siguientes)
                      Semantics(
                        label: condicionGeo(paso.numero('weather_code')),
                        child: Column(
                          spacing: 6,
                          children: [
                            Text(horaGeo(paso.hora)),
                            Icon(_icono(paso)),
                            Text(medidaGeo(paso.numero('temperature_2m'), '°')),
                            Text(
                              medidaGeo(
                                paso.numero('precipitation_probability'),
                                '%',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TarjetaApp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 9,
            children: [
              Text('Próximos 7 días', style: texto.titleMedium),
              if (pronostico.dias.isEmpty) const Text('Sin pronóstico diario'),
              for (final dia in pronostico.dias.take(7))
                Row(
                  spacing: 6,
                  children: [
                    Expanded(child: Text(diaGeo(dia.hora))),
                    Icon(_icono(dia), size: 17),
                    Text(
                      medidaGeo(
                        dia.numero('precipitation_probability_max'),
                        '%',
                      ),
                    ),
                    Text(medidaGeo(dia.numero('temperature_2m_min'), '°')),
                    Text(medidaGeo(dia.numero('temperature_2m_max'), '°')),
                  ],
                ),
            ],
          ),
        ),
        Text('Detalles del clima', style: texto.titleLarge),
        for (final (etiqueta, medida) in [
          (
            'Viento',
            '${valor('wind_speed_10m', ' km/h')} ${rumboViento(actual.numero('wind_direction_10m'))}',
          ),
          ('Ráfagas', valor('wind_gusts_10m', ' km/h')),
          ('Humedad', valor('relative_humidity_2m', ' %')),
          ('Presión en superficie', valor('surface_pressure', ' hPa')),
          (
            'Visibilidad horaria',
            medidaGeo(
              _kilometros(proxima?.numero('visibility')),
              ' km',
              decimales: 1,
            ),
          ),
          (
            'Índice UV horario',
            medidaGeo(proxima?.numero('uv_index'), '', decimales: 1),
          ),
          ('Nubosidad', valor('cloud_cover', ' %')),
          (
            'Probabilidad de lluvia horaria',
            medidaGeo(proxima?.numero('precipitation_probability'), ' %'),
          ),
          ('Precipitación', valor('precipitation', ' mm', decimales: 1)),
          ('Amanecer', horaGeo(hoy?.texto('sunrise') ?? '')),
          ('Atardecer', horaGeo(hoy?.texto('sunset') ?? '')),
        ])
          FichaCliente(titulo: etiqueta, subtitulo: medida),
        GraficaGeo(
          titulo: 'Temperatura por hora',
          pasos: pronostico.siguientes,
          campo: 'temperature_2m',
          unidad: ' °C',
        ),
        GraficaGeo(
          titulo: 'Precipitación por hora',
          pasos: pronostico.siguientes,
          campo: 'precipitation',
          unidad: ' mm',
        ),
        Text(
          'Fuente: Open-Meteo · Consulta: ${datos.consultado.toLocal().toString().substring(0, 16)} (dispositivo)',
          style: texto.bodySmall,
        ),
      ],
    );
  }
}

double? _kilometros(double? metros) => metros == null ? null : metros / 1000;

IconData _icono(PasoGeo paso) => switch (paso.numero('weather_code')?.toInt()) {
  0 || 1 =>
    paso.numero('is_day') == 0
        ? Icons.nights_stay_outlined
        : Icons.wb_sunny_outlined,
  2 || 3 || 45 || 48 => Icons.cloud_outlined,
  51 ||
  53 ||
  55 ||
  56 ||
  57 ||
  61 ||
  63 ||
  65 ||
  66 ||
  67 ||
  80 ||
  81 ||
  82 => Icons.water_drop_outlined,
  71 || 73 || 75 || 77 || 85 || 86 => Icons.ac_unit,
  95 || 96 || 99 => Icons.thunderstorm_outlined,
  _ => Icons.help_outline,
};
