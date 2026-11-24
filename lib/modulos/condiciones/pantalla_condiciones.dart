import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_geografico.dart';
import '../../compartido/widgets/panel_geografico.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/grafica_condiciones.dart';
import '../../compartido/widgets/superficie_cristal.dart';
import '../../compartido/widgets/selector_zona.dart';
import '../../compartido/widgets/fondo_atmosferico.dart';
import '../../nucleo/colores_app.dart';
import '../clima/pantalla_clima.dart';
import '../mareas/pantalla_mareas.dart';

class PantallaCondiciones extends StatefulWidget {
  const PantallaCondiciones({super.key, required this.entorno});
  final EntornoGeo entorno;
  @override
  State<PantallaCondiciones> createState() => _PantallaCondicionesState();
}

class _PantallaCondicionesState extends State<PantallaCondiciones> {
  int _metrica = 0;
  int _horas = 12;
  static const _series = [
    ('Temperatura', 'temperature_2m', ' °C', ColoresApp.etiqueta),
    ('Lluvia', 'precipitation_probability', ' %', ColoresApp.acento),
    ('Viento', 'wind_speed_10m', ' km/h', Color(0xFFD6C9A5)),
  ];
  Future<void> _actualizar() async {
    widget.entorno.actualizarClima();
    widget.entorno.actualizarMar();
    await Future.wait([widget.entorno.clima.value, widget.entorno.mar.value])
        .then<void>((_) {}, onError: (Object _, StackTrace _) {});
  }

  @override
  Widget build(BuildContext context) {
    final entorno = widget.entorno;
    return RefreshIndicator(
      onRefresh: _actualizar,
      child: ListView(
        key: const PageStorageKey('condiciones'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          EntradaCristal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIELO + MAR',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: ColoresApp.acento, letterSpacing: 2.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Condiciones',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tu próxima salida comienza aquí.',
                  style: TextStyle(color: ColoresApp.textoSecundario),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ConsultaGeo(
            consulta: entorno.clima,
            recargar: entorno.actualizarClima,
            builder: (respuesta) {
              final datos = respuesta.datos;
              final actual = datos.actual;
              return EntradaCristal(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: entorno.localidad,
                      builder: (_, lugar, _) => _ClimaPrincipal(
                        actual: actual,
                        hoy: datos.dias.firstOrNull,
                        localidad: lugar.nombre,
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, limites) {
                        final ancho =
                            limites.maxWidth < 340 ||
                                MediaQuery.textScalerOf(context).scale(1) > 1.4
                            ? limites.maxWidth
                            : (limites.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: ancho,
                              child: _Metrica(
                                titulo: 'Viento',
                                valor: medidaGeo(
                                  actual.numero('wind_speed_10m'),
                                  ' km/h',
                                ),
                                detalle:
                                    'Desde ${rumboViento(actual.numero('wind_direction_10m'))}',
                                icono: Icons.air,
                                color: ColoresApp.etiqueta,
                              ),
                            ),
                            SizedBox(
                              width: ancho,
                              child: _Metrica(
                                titulo: 'Prob. de lluvia',
                                valor: medidaGeo(
                                  datos.siguientes.firstOrNull?.numero(
                                    'precipitation_probability',
                                  ),
                                  ' %',
                                ),
                                detalle: 'Próxima hora',
                                icono: Icons.water_drop_outlined,
                                color: ColoresApp.acento,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Text(
                      'Open-Meteo · ${datos.zona} · Actualizado ${horaGeo(respuesta.consultado.toLocal().toIso8601String())} (dispositivo)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: entorno.costa,
            builder: (_, costa, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El mar en tu zona',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  costa.nombre,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ConsultaGeo(
            consulta: entorno.mar,
            recargar: entorno.actualizarMar,
            builder: (respuesta) {
              final actual = respuesta.datos.actual;
              return _Metrica(
                titulo: 'Oleaje',
                valor: medidaGeo(
                  actual.numero('wave_height'),
                  ' m',
                  decimales: 2,
                ),
                detalle:
                    '${rumboViento(actual.numero('wave_direction'))} · Período ${medidaGeo(actual.numero('wave_period'), ' s', decimales: 1)}',
                icono: Icons.waves_rounded,
                color: ColoresApp.etiqueta,
              );
            },
          ),
          const SizedBox(height: 14),
          _ProximasMareas(entorno: entorno),
          const SizedBox(height: 24),
          ConsultaGeo(
            consulta: entorno.clima,
            recargar: entorno.actualizarClima,
            resumen: true,
            builder: (respuesta) {
              final datos = respuesta.datos;
              final seleccion = _series[_metrica];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Próximas horas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (final horas in [12, 24])
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ChoiceChip(
                            label: Text('$horas h'),
                            selected: _horas == horas,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _horas = horas),
                          ),
                        ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        for (var i = 0; i < _series.length; i++)
                          ChoiceChip(
                            label: Text(_series[i].$1),
                            selected: _metrica == i,
                            onSelected: (_) => setState(() => _metrica = i),
                            showCheckmark: false,
                          ),
                      ],
                    ),
                  ),
                  GraficaCondiciones(
                    titulo: seleccion.$1,
                    pasos: datos.siguientes.take(_horas).toList(),
                    campo: seleccion.$2,
                    unidad: seleccion.$3,
                    color: seleccion.$4,
                    compacto: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('detalle_avanzado'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => _DetalleAvanzado(entorno: entorno),
              ),
            ),
            icon: const Icon(Icons.insights_rounded),
            label: const Text('Detalle avanzado'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pronósticos informativos. Consulta los avisos oficiales antes de salir al mar.',
            style: TextStyle(fontSize: 11, color: ColoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}

class _ClimaPrincipal extends StatelessWidget {
  const _ClimaPrincipal({
    required this.actual,
    required this.hoy,
    required this.localidad,
  });
  final PasoGeo actual;
  final PasoGeo? hoy;
  final String localidad;
  @override
  Widget build(BuildContext context) {
    final codigo = actual.numero('weather_code')?.toInt();
    final icono = codigo == null
        ? Icons.cloud_off_outlined
        : codigo <= 1
        ? (actual.numero('is_day') == 0
              ? Icons.nights_stay_outlined
              : Icons.wb_sunny_outlined)
        : codigo >= 95
        ? Icons.thunderstorm_outlined
        : codigo >= 51
        ? Icons.grain
        : Icons.cloud_outlined;
    return SuperficieCristal(
      premium: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: ColoresApp.acento,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  localidad,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 350),
                  child: Align(
                    key: ValueKey(actual.numero('temperature_2m')),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      medidaGeo(actual.numero('temperature_2m'), '°'),
                      style: const TextStyle(
                        fontSize: 68,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -4,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColoresApp.etiqueta.withValues(alpha: .3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(icono, size: 48, color: ColoresApp.etiqueta),
              ),
            ],
          ),
          Text(
            condicionGeo(actual.numero('weather_code')),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Sensación ${medidaGeo(actual.numero('apparent_temperature'), '°')}  ·  Máx. ${medidaGeo(hoy?.numero('temperature_2m_max'), '°')} / Mín. ${medidaGeo(hoy?.numero('temperature_2m_min'), '°')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.titulo,
    required this.valor,
    required this.detalle,
    required this.icono,
    required this.color,
  });
  final String titulo, valor, detalle;
  final IconData icono;
  final Color color;
  @override
  Widget build(BuildContext context) => TarjetaApp(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(titulo, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
        Text(valor, style: Theme.of(context).textTheme.headlineSmall),
        Text(detalle, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _DetalleAvanzado extends StatelessWidget {
  const _DetalleAvanzado({required this.entorno});
  final EntornoGeo entorno;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detalle avanzado'),
      actions: [
        IconButton(
          tooltip: 'Actualizar condiciones',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            entorno.actualizarClima();
            entorno.actualizarMar();
          },
        ),
        IconButton(
          tooltip: 'Elegir localidad y costa',
          icon: const Icon(Icons.edit_location_alt_outlined),
          onPressed: () => configurarZona(context, entorno),
        ),
      ],
    ),
    body: FondoAtmosferico(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ConsultaGeo(
            consulta: entorno.clima,
            recargar: entorno.actualizarClima,
            builder: (respuesta) => PronosticoClima(datos: respuesta),
          ),
          const SizedBox(height: 28),
          PantallaMareas(entorno: entorno, integrada: true),
        ],
      ),
    ),
  );
}

class _ProximasMareas extends StatelessWidget {
  const _ProximasMareas({required this.entorno});
  final EntornoGeo entorno;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: entorno.mar,
    builder: (_, futuro, _) => FutureBuilder(
      future: futuro,
      builder: (_, estado) {
        final proveedor = entorno.repo.mareas;
        if (proveedor == null) {
          return const TarjetaApp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text('Próximas mareas'),
                Text(
                  'Sin proveedor configurado. Los calendarios oficiales están en Detalle avanzado.',
                ),
              ],
            ),
          );
        }
        if (estado.hasError) {
          return TarjetaApp(
            child: TextButton(
              onPressed: entorno.actualizarMar,
              child: const Text(
                'No se pudo actualizar la zona costera · Reintentar',
              ),
            ),
          );
        }
        if (!estado.hasData) {
          return const TarjetaApp(
            child: Text('Esperando información de la zona costera…'),
          );
        }
        final fecha = diaGeo(estado.requireData.datos.actual.hora);
        if (fecha == '—') {
          return const Text(
            'Fecha de la zona costera no disponible. Consulta Detalle avanzado.',
          );
        }
        return _EventosMarea(
          key: ObjectKey(futuro),
          cargar: () async {
            final hoy = DateTime.parse(fecha);
            final eventos = await Future.wait([
              proveedor.extremos(entorno.costa.value, fecha),
              proveedor.extremos(
                entorno.costa.value,
                hoy
                    .add(const Duration(days: 1))
                    .toIso8601String()
                    .substring(0, 10),
              ),
            ]);
            return eventos.expand((e) => e).toList()
              ..sort((a, b) => a.hora.compareTo(b.hora));
          },
        );
      },
    ),
  );
}

class _EventosMarea extends StatefulWidget {
  const _EventosMarea({super.key, required this.cargar});
  final Future<List<EventoMarea>> Function() cargar;
  @override
  State<_EventosMarea> createState() => _EventosMareaState();
}

class _EventosMareaState extends State<_EventosMarea> {
  late Future<List<EventoMarea>> consulta = widget.cargar();
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: consulta,
    builder: (_, estado) {
      final proximas = estado.data
          ?.where((e) => e.hora.isAfter(DateTime.now()))
          .take(2)
          .toList();
      return TarjetaApp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              'Próximas mareas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (estado.hasError)
              TextButton(
                onPressed: () => setState(() => consulta = widget.cargar()),
                child: const Text('No se pudo consultar · Reintentar'),
              )
            else if (!estado.hasData)
              const Text('Consultando…')
            else if (proximas!.isEmpty)
              const Text(
                'Sin próximos eventos disponibles. Consulta otras fechas en Detalle avanzado.',
              )
            else
              for (final evento in proximas)
                Row(
                  children: [
                    Icon(
                      evento.pleamar ? Icons.north_east : Icons.south_east,
                      color: ColoresApp.acento,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(evento.pleamar ? 'Pleamar' : 'Bajamar'),
                    ),
                    Text(
                      '${diaGeo(evento.horaCivil ?? evento.hora.toIso8601String())}\n${horaGeo(evento.horaCivil ?? evento.hora.toIso8601String())} · ${medidaGeo(evento.alturaMetros, ' m', decimales: 2)}',
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
          ],
        ),
      );
    },
  );
}
