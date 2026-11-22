import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../compartido/modelos/clima_actual.dart';
import '../../compartido/servicios/servicio_clima.dart';
import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import '../../nucleo/modulo_app.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    super.key,
    required this.onAbrirModulo,
    required this.onAbrirPromociones,
  });

  final ValueChanged<ModuloApp> onAbrirModulo;
  final VoidCallback onAbrirPromociones;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<ClimaActual> _clima = ServicioClima.instancia.obtenerClima();

  Future<void> _actualizar() async {
    final consulta = ServicioClima.instancia.actualizarClima();
    setState(() {
      _clima = consulta;
    });
    try {
      await consulta;
    } catch (_) {
      // La tarjeta muestra el fallo y permite volver a consultar.
    }
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
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Text('¡Buena pesca!', style: texto.headlineMedium),
            const SizedBox(height: MedidasApp.pequeno),
            Text(
              'Ciudad del Carmen · Tu día de un vistazo',
              style: texto.bodySmall,
            ),
            const SizedBox(height: MedidasApp.interiorTarjeta),
            LayoutBuilder(
              builder: (context, limites) {
                final clima = FutureBuilder<ClimaActual>(
                  future: _clima,
                  builder: (context, resultado) {
                    final dato = resultado.data;
                    return _TarjetaInicio(
                      key: const Key('banner_clima'),
                      etiqueta: 'CLIMA',
                      anchoMinimo: 0,
                      altoMinimo: 183,
                      onTap: () => widget.onAbrirModulo(ModuloApp.clima),
                      children: [
                        if (dato != null) ...[
                          Text(
                            '${dato.temperatura.toStringAsFixed(1)}°',
                            style: texto.headlineMedium?.copyWith(fontSize: 38),
                          ),
                          Text(dato.descripcion, style: texto.bodySmall),
                          Text(
                            'Viento ${dato.velocidadViento.toStringAsFixed(0)} km/h',
                            style: texto.labelMedium,
                          ),
                        ] else
                          Text(
                            resultado.hasError
                                ? 'Información no disponible'
                                : 'Consultando clima…',
                            style: texto.titleMedium,
                          ),
                        const _EnlaceInicio('Ver pronóstico'),
                      ],
                    );
                  },
                );
                final mareas = _TarjetaInicio(
                  key: const Key('banner_mareas'),
                  etiqueta: 'MAREAS',
                  anchoMinimo: 0,
                  altoMinimo: 183,
                  onTap: () => widget.onAbrirModulo(ModuloApp.mareas),
                  children: [
                    Text('Sin datos', style: texto.titleLarge),
                    Text(
                      'Pleamar y bajamar aún no disponibles.',
                      style: texto.bodySmall,
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
                const _VistaMapa(),
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
    this.anchoMinimo = 0,
  });

  final String etiqueta;
  final double altoMinimo, anchoMinimo;
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
        constraints: BoxConstraints(
          minHeight: altoMinimo,
          minWidth: anchoMinimo,
        ),
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

class _VistaMapa extends StatelessWidget {
  const _VistaMapa();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(MedidasApp.radioControl),
    child: SizedBox(
      height: 100,
      child: LayoutBuilder(
        builder: (context, limites) => Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _CuadriculaMapa()),
            for (final (x, y) in [(70, 38), (169, 65), (222, 28)])
              Positioned(
                left: limites.maxWidth * x / 314 - 7,
                top: y - 7,
                child: SizedBox.square(
                  dimension: 14,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/inicio/punto.svg',
                        width: 14,
                        height: 14,
                      ),
                      SvgPicture.asset(
                        'assets/inicio/centro.svg',
                        width: 4,
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 9,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ColoresApp.tarjeta,
                  border: Border.all(color: ColoresApp.borde),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text(
                    'Vista de ejemplo',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CuadriculaMapa extends CustomPainter {
  const _CuadriculaMapa();

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()..color = ColoresApp.fondo;
    canvas.drawRect(Offset.zero & size, pintura);
    pintura
      ..color = const Color(0xff3f3f3f)
      ..strokeWidth = 2;
    for (final x in [22, 68, 114, 160, 206, 252, 298]) {
      final horizontal = x * size.width / 314;
      canvas.drawLine(
        Offset(horizontal, 0),
        Offset(horizontal, size.height),
        pintura,
      );
    }
    for (final y in [17.0, 42.0, 67.0, 92.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pintura);
    }
    pintura.color = const Color(0xff1c1c1c);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .61, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * .47, size.height)
        ..close(),
      pintura,
    );
  }

  @override
  bool shouldRepaint(_CuadriculaMapa oldDelegate) => false;
}
