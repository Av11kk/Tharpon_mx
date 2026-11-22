import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/catalogo_cliente.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/panel_geografico.dart';
import '../../nucleo/colores_app.dart';

LatLng? coordenadaPunto(FilaCliente fila) {
  final latitud = fila['latitud'];
  final longitud = fila['longitud'];
  if (latitud is! num ||
      longitud is! num ||
      !latitud.isFinite ||
      !longitud.isFinite ||
      latitud.abs() > 90 ||
      longitud.abs() > 180) {
    return null;
  }
  return LatLng(latitud.toDouble(), longitud.toDouble());
}

List<String> especiesPunto(FilaCliente fila) => [
  for (final vinculo in fila['puntos_especies'] as List? ?? [])
    if (vinculo case {
      'especies': {'publicado': true, 'nombre': final String nombre},
    })
      nombre,
];

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({
    super.key,
    required this.entorno,
    required this.puntos,
    this.repo,
    this.teselas = true,
  });
  final EntornoGeo entorno;
  final ValueNotifier<Future<List<FilaCliente>>> puntos;
  final RepositorioCliente? repo;
  final bool teselas;

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _mapa = MapController();
  String _busqueda = '';
  LatLng? _gps;
  bool _localizando = false;
  bool _mapaListo = false;
  bool _falloMapa = false;
  int _versionMapa = 0;
  static const _centro = LatLng(18.64592, -91.82991);
  static const _osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _url = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: kReleaseMode ? '' : _osm,
  );
  static const _atribucion = String.fromEnvironment('MAP_TILE_ATTRIBUTION');

  @override
  void dispose() {
    _mapa.dispose();
    super.dispose();
  }

  void _centrar(LatLng destino, double zoom) {
    if (_mapaListo) _mapa.move(destino, zoom);
  }

  Future<void> _usarUbicacion() async {
    setState(() => _localizando = true);
    try {
      final sitio = await widget.entorno.localidad.localizar();
      if (!mounted) return;
      final punto = LatLng(sitio.latitud, sitio.longitud);
      setState(() => _gps = punto);
      _centrar(punto, 12);
    } catch (error) {
      if (mounted) {
        avisoCliente(
          context,
          error is FormatException
              ? error.message
              : 'No se pudo obtener la ubicación.',
        );
      }
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  void _detalle(FilaCliente fila) {
    final foto = fila['imagen_path'] as String?;
    final especies = especiesPunto(fila);
    abrirCliente<void>(
      context,
      DetalleCliente(
        titulo: dato(fila, 'nombre'),
        fotos: [
          if (foto != null && foto.isNotEmpty && widget.repo != null)
            FotoCliente(repo: widget.repo!, ruta: foto),
        ],
        children: [
          if (dato(fila, 'descripcion').isNotEmpty)
            Text(dato(fila, 'descripcion')),
          const EncabezadoApp(titulo: 'Especies asociadas'),
          if (especies.isEmpty)
            const Text('Sin especies publicadas asociadas.'),
          for (final especie in especies) FichaCliente(titulo: especie),
        ],
      ),
    );
  }

  void _lista(List<FilaCliente> filas) {
    abrirCliente<void>(
      context,
      pantallaCliente(
        'Explorar lugares',
        ListaCliente(
          children: [
            if (filas.isEmpty)
              const Text('No hay puntos de pesca que mostrar.'),
            for (final fila in filas)
              FichaCliente(
                titulo: dato(fila, 'nombre'),
                alAbrir: () => _detalle(fila),
              ),
          ],
        ),
      ),
    );
  }

  void _actualizar() {
    final consulta =
        widget.repo?.puntosPesca() ?? Future.value(<FilaCliente>[]);
    consulta.ignore();
    widget.puntos.value = consulta;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.puntos,
    builder: (context, futuro, _) => FutureBuilder(
      future: futuro,
      builder: (context, estado) {
        final filas = (estado.data ?? [])
            .where(
              (fila) =>
                  fila['publicado'] == true &&
                  coordenadaPunto(fila) != null &&
                  coincideBusqueda([
                    dato(fila, 'nombre'),
                    dato(fila, 'descripcion'),
                    ...especiesPunto(fila),
                  ], _busqueda),
            )
            .toList();
        final proveedor =
            widget.teselas &&
            _url.startsWith('https://') &&
            ['{x}', '{y}', '{z}'].every(_url.contains) &&
            (_url == _osm || _atribucion.isNotEmpty);
        return ListaCliente(
          children: [
            const EncabezadoApp(titulo: 'Mapa', destacado: true),
            TextField(
              onChanged: (valor) => setState(() => _busqueda = valor),
              decoration: const InputDecoration(
                labelText: 'Buscar lugares de pesca',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(
              height:
                  MediaQuery.sizeOf(context).height.clamp(280.0, 640.0) * .58,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapa,
                  options: MapOptions(
                    initialCenter: _centro,
                    initialZoom: 11,
                    minZoom: 2,
                    maxZoom: 18,
                    backgroundColor: ColoresApp.superficie,
                    onMapReady: () => _mapaListo = true,
                  ),
                  children: [
                    if (proveedor)
                      TileLayer(
                        key: ValueKey(_versionMapa),
                        urlTemplate: _url,
                        userAgentPackageName: 'com.example.tharpom_mx',
                        errorTileCallback: (_, _, _) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && !_falloMapa) {
                              setState(() => _falloMapa = true);
                            }
                          });
                        },
                      ),
                    MarkerLayer(
                      markers: [
                        for (final (i, fila) in filas.indexed)
                          Marker(
                            point: coordenadaPunto(fila)!,
                            width: 44,
                            height: 44,
                            child: IconButton(
                              key: ValueKey('punto_${fila['id']}'),
                              tooltip: dato(fila, 'nombre'),
                              onPressed: () => _detalle(fila),
                              style: IconButton.styleFrom(
                                foregroundColor: ColoresApp.tarjeta,
                                backgroundColor: ColoresApp.accion,
                              ),
                              icon: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_gps case final posicion?)
                          Marker(
                            point: posicion,
                            child: const Tooltip(
                              message: 'Tu ubicación aproximada',
                              child: Icon(Icons.my_location),
                            ),
                          ),
                      ],
                    ),
                    if (proveedor)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                          color: ColoresApp.tarjeta,
                          child: _url == _osm
                              ? InkWell(
                                  onTap: () => launchUrl(
                                    Uri.https(
                                      'www.openstreetmap.org',
                                      '/copyright',
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Text(
                                      '© OpenStreetMap contributors',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(_atribucion),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!proveedor)
              const Text('Cartografía sin proveedor HTTPS configurado.'),
            if (_falloMapa)
              TextButton(
                onPressed: () => setState(() {
                  _versionMapa++;
                  _falloMapa = false;
                }),
                child: const Text(
                  'No se cargaron algunas teselas · Reintentar',
                ),
              ),
            Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Actualizar puntos',
                  onPressed: _actualizar,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Acercar',
                  onPressed: () {
                    if (_mapaListo) {
                      _centrar(
                        _mapa.camera.center,
                        (_mapa.camera.zoom + 1).clamp(2, 18).toDouble(),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  tooltip: 'Alejar',
                  onPressed: () {
                    if (_mapaListo) {
                      _centrar(
                        _mapa.camera.center,
                        (_mapa.camera.zoom - 1).clamp(2, 18).toDouble(),
                      );
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  tooltip: 'Centrar mapa',
                  onPressed: () => _centrar(_gps ?? _centro, 11),
                  icon: const Icon(Icons.center_focus_strong),
                ),
                IconButton(
                  tooltip: 'Usar mi ubicación',
                  onPressed: _localizando ? null : _usarUbicacion,
                  icon: const Icon(Icons.my_location),
                ),
              ],
            ),
            if (estado.hasError)
              TextButton(
                onPressed: _actualizar,
                child: const Text('Puntos no disponibles · Reintentar'),
              )
            else if (estado.connectionState != ConnectionState.done)
              const Text('Consultando puntos de pesca…')
            else if (filas.isEmpty)
              Text(
                _busqueda.trim().isEmpty
                    ? 'Aún no hay puntos de pesca publicados.'
                    : 'No hay coincidencias.',
              ),
            BotonPrincipal(
              texto: 'Explorar lugares',
              alPulsar: () => _lista(filas),
              icono: Icons.list,
            ),
          ],
        );
      },
    ),
  );
}
