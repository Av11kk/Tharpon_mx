import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:tharpom_mx/nucleo/tema_app.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  EstiloTarpon _estilo = EstiloTarpon.oceano;

  @override
  Widget build(BuildContext context) {
    final p = _estilo;
    return FTheme(
      data: p.temaForui,
      child: FScaffold(
        childPad: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  _Encabezado(
                    p: p,
                    onCambiar: () => setState(() => _estilo = p.siguiente),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                      children: [
                        _Bienvenida(p: p),
                        const SizedBox(height: 20),
                        _Clima(p: p),
                        const SizedBox(height: 24),
                        _TituloSeccion(
                          p: p,
                          titulo: 'El mar hoy',
                          subtitulo: 'Un vistazo a las condiciones',
                        ),
                        const SizedBox(height: 12),
                        _Mareas(p: p),
                        const SizedBox(height: 26),
                        _TituloSeccion(
                          p: p,
                          titulo: 'Lugares para explorar',
                          subtitulo: 'Cerca de Ciudad del Carmen',
                        ),
                        const SizedBox(height: 12),
                        _Lugares(p: p),
                        const SizedBox(height: 26),
                        _TituloSeccion(
                          p: p,
                          titulo: 'Equipo recomendado',
                          subtitulo: 'Listo para tu próxima salida',
                        ),
                        const SizedBox(height: 12),
                        _Productos(p: p),
                        const SizedBox(height: 22),
                        Text(
                          'Información y precios de ejemplo · Sin conexión a servicios',
                          style: TextStyle(color: p.secundario, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _Navegacion(p: p),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.p, required this.onCambiar});
  final EstiloTarpon p;
  final VoidCallback onCambiar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: p.acento,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.waves_rounded, color: p.contraste, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARPON',
                    style: TextStyle(
                      color: p.texto,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  Text(
                    'CIUDAD DEL CARMEN',
                    style: TextStyle(
                      color: p.secundario,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.location_on_outlined, size: 15, color: p.acento),
            const SizedBox(width: 3),
            Text(
              'Campeche',
              style: TextStyle(color: p.secundario, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPUESTA ${p.numero} / 03',
                    style: TextStyle(
                      color: p.acento,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.texto,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 154,
              child: FButton(
                onPress: onCambiar,
                child: const SizedBox(
                  width: 118,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Cambiar estilo'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Bienvenida extends StatelessWidget {
  const _Bienvenida({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'TU PRÓXIMA AVENTURA',
        style: TextStyle(
          color: p.acento,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'El mar te espera.',
        style: TextStyle(
          color: p.texto,
          fontSize: 29,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Todo listo para salir a pescar.',
        style: TextStyle(color: p.secundario, fontSize: 14),
      ),
    ],
  );
}

class _Clima extends StatelessWidget {
  const _Clima({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => FCard(
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.gradiente,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CLIMA DE EJEMPLO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFFDD92),
                size: 27,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '28°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  height: .95,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parcialmente soleado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ciudad del Carmen',
                        style: TextStyle(
                          color: Color(0xFFD6ECE9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _DatoClima(
                  icono: Icons.air_rounded,
                  titulo: 'VIENTO',
                  valor: '12 km/h',
                ),
              ),
              Expanded(
                child: _DatoClima(
                  icono: Icons.water_drop_outlined,
                  titulo: 'HUMEDAD',
                  valor: '72%',
                ),
              ),
              Expanded(
                child: _DatoClima(
                  icono: Icons.waves_rounded,
                  titulo: 'OLEAJE',
                  valor: '0.4 m',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DatoClima extends StatelessWidget {
  const _DatoClima({
    required this.icono,
    required this.titulo,
    required this.valor,
  });
  final IconData icono;
  final String titulo;
  final String valor;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icono, size: 13, color: const Color(0xFFBFE9E1)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFBFE9E1),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        valor,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({
    required this.p,
    required this.titulo,
    required this.subtitulo,
  });
  final EstiloTarpon p;
  final String titulo;
  final String subtitulo;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titulo,
        style: TextStyle(
          color: p.texto,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
      ),
      const SizedBox(height: 3),
      Text(subtitulo, style: TextStyle(color: p.secundario, fontSize: 12)),
    ],
  );
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => FCard(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class _Mareas extends StatelessWidget {
  const _Mareas({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => _Tarjeta(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Icono(p: p, icono: Icons.waves_rounded, color: p.acento),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mareas',
                    style: TextStyle(
                      color: p.texto,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Laguna de Términos',
                    style: TextStyle(color: p.secundario, fontSize: 11),
                  ),
                ],
              ),
            ),
            _Etiqueta(texto: 'EJEMPLO', color: p.acento),
          ],
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: _MareaDato(
                p: p,
                nombre: 'PLEAMAR',
                hora: '08:40',
                altura: '0.7 m',
                icono: Icons.north_east_rounded,
              ),
            ),
            Container(width: 1, height: 38, color: p.borde),
            const SizedBox(width: 18),
            Expanded(
              child: _MareaDato(
                p: p,
                nombre: 'BAJAMAR',
                hora: '15:20',
                altura: '0.2 m',
                icono: Icons.south_east_rounded,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MareaDato extends StatelessWidget {
  const _MareaDato({
    required this.p,
    required this.nombre,
    required this.hora,
    required this.altura,
    required this.icono,
  });
  final EstiloTarpon p;
  final String nombre, hora, altura;
  final IconData icono;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icono, size: 14, color: p.acento),
          const SizedBox(width: 4),
          Text(
            nombre,
            style: TextStyle(
              color: p.secundario,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        '$hora  ·  $altura',
        style: TextStyle(
          color: p.texto,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _Icono extends StatelessWidget {
  const _Icono({required this.p, required this.icono, required this.color});
  final EstiloTarpon p;
  final IconData icono;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: p.oscuro ? .18 : .10),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icono, color: color, size: 21),
  );
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.color});
  final String texto;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}

class _Lugares extends StatelessWidget {
  const _Lugares({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _Lugar(
          p: p,
          nombre: 'Laguna de Términos',
          descripcion: 'Aguas tranquilas · Laguna',
          icono: Icons.landscape_rounded,
          color: p.acento,
        ),
        const SizedBox(width: 12),
        _Lugar(
          p: p,
          nombre: 'Isla Aguada',
          descripcion: 'Costa y manglares',
          icono: Icons.beach_access_rounded,
          color: p.destacado,
        ),
      ],
    ),
  );
}

class _Lugar extends StatelessWidget {
  const _Lugar({
    required this.p,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
  });
  final EstiloTarpon p;
  final String nombre, descripcion;
  final IconData icono;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 225,
    child: _Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Icono(p: p, icono: icono, color: color),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: p.secundario, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.texto,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.secundario, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _Productos extends StatelessWidget {
  const _Productos({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Producto(
        p: p,
        icono: Icons.set_meal_rounded,
        nombre: 'Señuelo de superficie',
        detalle: 'Para agua salada',
        precio: '\$189 MXN',
        color: p.acento,
      ),
      const SizedBox(height: 10),
      _Producto(
        p: p,
        icono: Icons.phishing_rounded,
        nombre: 'Línea trenzada',
        detalle: 'Resistencia 20 lb',
        precio: '\$320 MXN',
        color: p.destacado,
      ),
    ],
  );
}

class _Producto extends StatelessWidget {
  const _Producto({
    required this.p,
    required this.icono,
    required this.nombre,
    required this.detalle,
    required this.precio,
    required this.color,
  });
  final EstiloTarpon p;
  final IconData icono;
  final String nombre, detalle, precio;
  final Color color;
  @override
  Widget build(BuildContext context) => _Tarjeta(
    child: Row(
      children: [
        _Icono(p: p, icono: icono, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.texto,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detalle,
                style: TextStyle(color: p.secundario, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          precio,
          style: TextStyle(
            color: p.acento,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _Navegacion extends StatelessWidget {
  const _Navegacion({required this.p});
  final EstiloTarpon p;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: p.superficie,
      border: Border(top: BorderSide(color: p.borde)),
    ),
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Destino(
          p: p,
          icono: Icons.home_rounded,
          nombre: 'Inicio',
          activo: true,
        ),
        _Destino(p: p, icono: Icons.map_outlined, nombre: 'Lugares'),
        _Destino(p: p, icono: Icons.waves_rounded, nombre: 'Mareas'),
        _Destino(p: p, icono: Icons.storefront_outlined, nombre: 'Tienda'),
      ],
    ),
  );
}

class _Destino extends StatelessWidget {
  const _Destino({
    required this.p,
    required this.icono,
    required this.nombre,
    this.activo = false,
  });
  final EstiloTarpon p;
  final IconData icono;
  final String nombre;
  final bool activo;
  @override
  Widget build(BuildContext context) {
    final color = activo ? p.acento : p.secundario;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: 21),
        const SizedBox(height: 3),
        Text(
          nombre,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
