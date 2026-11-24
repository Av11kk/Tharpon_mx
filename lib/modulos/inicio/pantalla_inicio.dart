import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_geografico.dart';
import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/panel_geografico.dart';
import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import '../../nucleo/modulo_app.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
    required this.onAbrirModulo,
    required this.onAbrirPromociones,
    required this.entorno,
    required this.puntos,
  });

  final ValueChanged<ModuloApp> onAbrirModulo;
  final VoidCallback onAbrirPromociones;
  final EntornoGeo entorno;
  final ValueNotifier<Future<List<FilaCliente>>> puntos;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  Future<void> _actualizar() async {
    widget.entorno.actualizarClima();
    widget.entorno.actualizarMar();
    await Future.wait([widget.entorno.clima.value, widget.entorno.mar.value])
        .then<void>((_) {}, onError: (Object _, StackTrace _) {});
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _actualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            22,
            16,
            22,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text('¡Buena pesca!', style: texto.headlineMedium),
            const SizedBox(height: MedidasApp.pequeno),
            ValueListenableBuilder(
              valueListenable: widget.entorno.localidad,
              builder: (context, localidad, _) => Text(
                '${localidad.nombre} · Tu día de un vistazo',
                style: texto.bodySmall,
              ),
            ),
            const SizedBox(height: MedidasApp.interiorTarjeta),
            LayoutBuilder(
              builder: (context, limites) {
                final clima = _TarjetaInicio(
                  key: const Key('banner_clima'),
                  etiqueta: 'CLIMA',
                  altoMinimo: 183,
                  onTap: () => widget.onAbrirModulo(ModuloApp.clima),
                  children: [
                    ConsultaGeo(
                      consulta: widget.entorno.clima,
                      recargar: widget.entorno.actualizarClima,
                      resumen: true,
                      builder: (dato) {
                        final actual = dato.datos.actual;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medidaGeo(actual.numero('temperature_2m'), '°'),
                              style: texto.headlineMedium,
                            ),
                            Text(
                              condicionGeo(actual.numero('weather_code')),
                              style: texto.bodySmall,
                            ),
                            Text(
                              'Viento ${medidaGeo(actual.numero('wind_speed_10m'), ' km/h')}',
                              style: texto.labelMedium,
                            ),
                          ],
                        );
                      },
                    ),
                    const _EnlaceInicio('Ver pronóstico'),
                  ],
                );
                final mareas = _TarjetaInicio(
                  key: const Key('banner_mareas'),
                  etiqueta: 'MAREAS',
                  altoMinimo: 183,
                  onTap: () => widget.onAbrirModulo(ModuloApp.mareas),
                  children: [
                    ConsultaGeo(
                      consulta: widget.entorno.mar,
                      recargar: widget.entorno.actualizarMar,
                      resumen: true,
                      builder: (dato) {
                        final actual = dato.datos.actual;
                        final altura = actual.numero('wave_height');
                        return Text(
                          altura == null
                              ? 'Oleaje sin datos'
                              : 'Oleaje ${medidaGeo(altura, ' m', decimales: 1)}',
                          style: texto.titleMedium,
                        );
                      },
                    ),
                    const _EnlaceInicio('Ver mareas'),
                  ],
                );
                final ancho = (limites.maxWidth - MedidasApp.medio) / 2;
                final ladoALado =
                    ancho >= MediaQuery.textScalerOf(context).scale(126);
                return Wrap(
                  spacing: MedidasApp.medio,
                  runSpacing: MedidasApp.medio,
                  children: [
                    for (final tarjeta in [clima, mareas])
                      SizedBox(
                        width: ladoALado ? ancho : limites.maxWidth,
                        child: tarjeta,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: MedidasApp.normal),
            _TarjetaInicio(
              key: const Key('banner_equipo'),
              etiqueta: 'EQUIPO',
              onTap: () => widget.onAbrirModulo(ModuloApp.equipo),
              children: [
                Text('Prepara tu próxima salida', style: texto.titleLarge),
                for (final categoria in [
                  'Cañas y carretes',
                  'Señuelos y accesorios',
                ])
                  _CategoriaEquipo(
                    categoria: categoria,
                    onTap: () => widget.onAbrirModulo(ModuloApp.equipo),
                  ),
              ],
            ),
            const SizedBox(height: MedidasApp.normal),
            _TarjetaInicio(
              key: const Key('banner_mapa'),
              etiqueta: 'MAPA',
              onTap: () => widget.onAbrirModulo(ModuloApp.mapa),
              children: [
                Text('Encuentra tu próximo punto', style: texto.titleLarge),
                ValueListenableBuilder(
                  valueListenable: widget.puntos,
                  builder: (context, futuro, _) => FutureBuilder(
                    future: futuro,
                    builder: (context, resultado) => Text(
                      resultado.hasError
                          ? 'Puntos no disponibles'
                          : resultado.hasData
                          ? (resultado.requireData.isEmpty
                                ? 'Sin puntos publicados'
                                : '${resultado.requireData.length} puntos publicados')
                          : 'Consultando puntos…',
                    ),
                  ),
                ),
                const _EnlaceInicio('Explorar mapa'),
              ],
            ),
            const SizedBox(height: MedidasApp.pequeno),
            TextButton(
              key: const Key('banner_promociones'),
              onPressed: widget.onAbrirPromociones,
              child: const Text('Ver promociones'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaInicio extends StatelessWidget {
  const _TarjetaInicio({
    super.key,
    required this.etiqueta,
    required this.onTap,
    required this.children,
    this.altoMinimo = 0,
  });

  final String etiqueta;
  final double altoMinimo;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(MedidasApp.radioTarjetaAcceso),
      ),
      side: BorderSide(color: ColoresApp.bordeTarjetaAcceso),
    ),
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: altoMinimo),
        child: Padding(
          padding: const EdgeInsets.all(MedidasApp.normal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: MedidasApp.pequeno,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      etiqueta,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.north_east, size: 16),
                ],
              ),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

class _CategoriaEquipo extends StatelessWidget {
  const _CategoriaEquipo({required this.categoria, required this.onTap});
  final String categoria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: ColoresApp.superficie,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(MedidasApp.radioCampoRegistro),
      ),
      side: BorderSide(color: ColoresApp.borde),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(MedidasApp.radioCampoRegistro),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categoria,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    ),
  );
}

class _EnlaceInicio extends StatelessWidget {
  const _EnlaceInicio(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(
          texto,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 11),
        ),
      ),
      const SizedBox(width: 6),
      const Icon(Icons.arrow_forward, size: 14),
    ],
  );
}
