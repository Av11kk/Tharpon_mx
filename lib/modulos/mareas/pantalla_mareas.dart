import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../compartido/servicios/servicio_geografico.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/panel_geografico.dart';

class PantallaMareas extends StatefulWidget {
  const PantallaMareas({
    super.key,
    required this.entorno,
    this.integrada = false,
  });
  final EntornoGeo entorno;
  final bool integrada;
  @override
  State<PantallaMareas> createState() => _PantallaMareasState();
}

class _PantallaMareasState extends State<PantallaMareas> {
  @override
  void initState() {
    super.initState();
    widget.entorno.costa.addListener(_reiniciarZona);
  }

  void _reiniciarZona() => setState(() {
    _fecha = null;
    _extremos = null;
  });
  @override
  void dispose() {
    widget.entorno.costa.removeListener(_reiniciarZona);
    super.dispose();
  }

  String? _fecha;
  Future<List<EventoMarea>>? _extremos;

  Widget _contenido(List<Widget> children) => widget.integrada
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: children,
        )
      : ListaCliente(children: children);

  void _elegirFecha(String fecha) {
    final proveedor = widget.entorno.repo.mareas;
    final extremos = proveedor?.extremos(widget.entorno.costa.value, fecha);
    extremos?.ignore();
    setState(() {
      _fecha = fecha;
      _extremos = extremos;
    });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.entorno.costa,
    builder: (context, costa, _) => _contenido([
      EncabezadoApp(
        titulo: 'Mareas',
        descripcion: costa.nombre,
        destacado: true,
      ),
      const Text('Información de Mareas'),
      ConsultaGeo(
        consulta: widget.entorno.mar,
        recargar: widget.entorno.actualizarMar,
        builder: (respuesta) {
          final datos = respuesta.datos;
          final fechas = datos.horas
              .map((p) => diaGeo(p.hora))
              .where((s) => s != '—')
              .toSet()
              .toList();
          final fecha = fechas.contains(_fecha) ? _fecha : fechas.firstOrNull;
          final horas = datos.horas
              .where((p) => diaGeo(p.hora) == fecha)
              .toList();
          final actual = datos.actual;
          final nivel = horas.any(
            (p) => p.numero('sea_level_height_msl') != null,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (fechas.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: ValueKey(fecha),
                  initialValue: fecha,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha del pronóstico',
                  ),
                  items: [
                    for (final dia in fechas)
                      DropdownMenuItem(value: dia, child: Text(dia)),
                  ],
                  onChanged: (dia) {
                    if (dia != null) _elegirFecha(dia);
                  },
                ),
              TarjetaApp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const Text('Oleaje actual'),
                    Text(
                      medidaGeo(
                        actual.numero('wave_height'),
                        ' m',
                        decimales: 2,
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Dirección: ${rumboViento(actual.numero('wave_direction'))} · Período: ${medidaGeo(actual.numero('wave_period'), ' s', decimales: 1)}',
                    ),
                  ],
                ),
              ),
              GraficaGeo(
                titulo: 'Altura del oleaje',
                pasos: horas,
                campo: 'wave_height',
                unidad: ' m',
              ),
              GraficaGeo(
                titulo: 'Nivel del mar respecto a MSL',
                pasos: horas,
                campo: 'sea_level_height_msl',
                unidad: ' m',
              ),
              if (nivel) const Text('La serie es un nivel de mar modelado.'),
              const EncabezadoApp(titulo: 'Pleamar y bajamar'),
              if (widget.entorno.repo.mareas == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Horarios y alturas de marea sin proveedor configurado.',
                    ),
                    TextButton(
                      onPressed: () async {
                        final abierto = await launchUrl(
                          Uri.https(
                            'oceanografia.semar.gob.mx',
                            '/estaciones.html',
                          ),
                        );
                        if (!abierto && context.mounted) {
                          avisoCliente(
                            context,
                            'No se pudo abrir el calendario oficial.',
                          );
                        }
                      },
                      child: const Text('Consultar calendarios de SEMAR'),
                    ),
                  ],
                )
              else if (_extremos == null)
                TextButton(
                  onPressed: fecha == null ? null : () => _elegirFecha(fecha),
                  child: const Text('Consultar horarios'),
                ),
              if (_extremos case final extremos?)
                FutureBuilder(
                  future: extremos,
                  builder: (context, estado) {
                    if (estado.hasError) {
                      return TextButton(
                        onPressed: fecha == null
                            ? null
                            : () => _elegirFecha(fecha),
                        child: const Text(
                          'No se pudieron consultar los horarios · Reintentar',
                        ),
                      );
                    }
                    if (!estado.hasData) {
                      return const Text('Consultando horarios…');
                    }
                    if (estado.requireData.isEmpty) {
                      return const Text(
                        'Sin predicción para esta zona y fecha.',
                      );
                    }
                    return Column(
                      children: [
                        for (final evento in estado.requireData)
                          FichaCliente(
                            titulo: evento.pleamar ? 'Pleamar' : 'Bajamar',
                            subtitulo:
                                '${(evento.horaCivil ?? evento.hora.toUtc().toIso8601String()).replaceFirst('T', ' ')} · ${medidaGeo(evento.alturaMetros, ' m', decimales: 2)}',
                          ),
                        Text(
                          'Fuente de mareas: ${widget.entorno.repo.mareas!.fuente}',
                        ),
                      ],
                    );
                  },
                ),
              if (horas.isNotEmpty)
                TarjetaApp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      ExpansionTile(
                        title: const Text('Pronóstico marítimo por hora'),
                        children: [
                          for (final hora in horas)
                            Text(
                              '${horaGeo(hora.hora)} · ${medidaGeo(hora.numero('wave_height'), ' m', decimales: 2)} · ${rumboViento(hora.numero('wave_direction'))} · ${medidaGeo(hora.numero('wave_period'), ' s', decimales: 1)}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              Text('Fuente: Open-Meteo Marine · ${datos.zona}'),
              Text(
                'Consulta: ${respuesta.consultado.toLocal().toString().substring(0, 16)} (dispositivo)',
              ),
            ],
          );
        },
      ),
      const Text(
        'Pronósticos informativos. Consulta los avisos oficiales antes de salir al mar.',
      ),
    ]),
  );
}
