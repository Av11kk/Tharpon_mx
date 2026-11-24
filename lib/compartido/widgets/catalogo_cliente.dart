import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../servicios/repositorio_cliente.dart';
import 'contenido_cliente.dart';
import 'controles_app.dart';
import 'estado_operacion.dart';

enum TipoCatalogo { especies, consejos, equipo }

String precioMx(Object? cantidad) =>
    'MXN ${(cantidad as num).toStringAsFixed(2)}';

class DetalleCliente extends StatelessWidget {
  const DetalleCliente({
    super.key,
    required this.titulo,
    required this.children,
    this.fotos = const [],
  });
  final String titulo;
  final List<Widget> children, fotos;

  @override
  Widget build(BuildContext context) => pantallaCliente(
    titulo,
    ListaCliente(
      children: [
        if (fotos.isNotEmpty)
          SizedBox(
            height: 240,
            child: PageView(
              children: [
                for (var i = 0; i < fotos.length; i++)
                  Semantics(
                    label: 'Fotografía ${i + 1} de ${fotos.length}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: fotos[i],
                    ),
                  ),
              ],
            ),
          ),
        if (fotos.length > 1)
          Text('${fotos.length} fotos · Desliza para ver la galería'),
        EncabezadoApp(titulo: titulo),
        ...children,
      ],
    ),
  );
}

class CatalogoCliente extends StatefulWidget {
  const CatalogoCliente({
    super.key,
    required this.repo,
    required this.tipo,
    this.cabecera = const [],
    this.abrirProducto,
  });
  final RepositorioCliente repo;
  final TipoCatalogo tipo;
  final List<Widget> cabecera;
  final void Function(FilaCliente)? abrirProducto;

  @override
  State<CatalogoCliente> createState() => _CatalogoClienteState();
}

class _CatalogoClienteState extends State<CatalogoCliente> {
  String _busqueda = '';
  String? _categoria;
  bool _soloFavoritos = false;
  bool _guardando = false;
  final _favoritos = ValueNotifier<Set<String>>({});

  bool get _especies => widget.tipo == TipoCatalogo.especies;
  bool get _consejos => widget.tipo == TipoCatalogo.consejos;

  @override
  void dispose() {
    _favoritos.dispose();
    super.dispose();
  }

  Future<(List<FilaCliente>, List<FilaCliente>)> _cargar() async {
    final repo = widget.repo;
    if (_especies) return (await repo.especies(), <FilaCliente>[]);
    final resultado = await Future.wait([
      _consejos ? repo.consejos() : repo.productos(),
      repo.categorias(equipo: !_consejos),
      if (_consejos) repo.favoritos(),
    ]);
    if (_consejos && mounted) _favoritos.value = resultado[2] as Set<String>;
    return (
      resultado[0] as List<FilaCliente>,
      resultado[1] as List<FilaCliente>,
    );
  }

  Future<void> _alternar(BuildContext contexto, String id) async {
    if (_guardando) return;
    _guardando = true;
    final guardados = _favoritos.value;
    final quitar = guardados.contains(id);
    try {
      await widget.repo.favorito(id, !quitar);
      if (mounted) {
        final actualizados = {...guardados};
        if (quitar) {
          actualizados.remove(id);
        } else {
          actualizados.add(id);
        }
        _favoritos.value = actualizados;
      }
    } catch (_) {
      if (contexto.mounted) {
        avisoCliente(contexto, 'No se pudo actualizar el favorito.');
      }
    } finally {
      _guardando = false;
    }
  }

  Widget _botonFavorito(String id) => ValueListenableBuilder(
    valueListenable: _favoritos,
    builder: (context, guardados, _) {
      final guardado = guardados.contains(id);
      return IconButton(
        tooltip: guardado ? 'Quitar favorito' : 'Guardar favorito',
        isSelected: guardado,
        onPressed: () => _alternar(context, id),
        icon: const Icon(Icons.bookmark_border),
        selectedIcon: const Icon(Icons.bookmark),
      );
    },
  );

  String _titulo(FilaCliente fila) =>
      dato(fila, _consejos ? 'titulo' : 'nombre');

  Widget? _foto(FilaCliente fila) {
    final ruta = _especies || _consejos
        ? fila['imagen_path'] as String?
        : rutasProducto(fila).firstOrNull;
    return ruta == null || ruta.isEmpty
        ? null
        : FotoCliente(repo: widget.repo, ruta: ruta);
  }

  void _detalle(FilaCliente fila) {
    if (widget.abrirProducto case final abrir?) {
      abrir(fila);
      return;
    }
    final foto = _foto(fila);
    abrirCliente<void>(
      context,
      DetalleCliente(
        titulo: _titulo(fila),
        fotos: [?foto],
        children: [
          if (_consejos) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _botonFavorito(fila['id'] as String),
            ),
            if (dato(fila, 'resumen').isNotEmpty) Text(dato(fila, 'resumen')),
            Text(dato(fila, 'contenido')),
          ] else
            for (final (campo, etiqueta) in [
              ('nombre_cientifico', 'Nombre científico'),
              ('descripcion', 'Descripción'),
              ('habitat', 'Hábitat'),
              ('recomendaciones', 'Recomendaciones'),
            ])
              if (dato(fila, campo).isNotEmpty)
                FichaCliente(titulo: etiqueta, subtitulo: dato(fila, campo)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ConsultaCliente(
    cargar: _cargar,
    cabecera: widget.cabecera.isEmpty
        ? null
        : Column(children: widget.cabecera),
    builder:
        (
          context,
          (List<FilaCliente>, List<FilaCliente>) datos,
          recargar,
        ) => ValueListenableBuilder(
          valueListenable: _favoritos,
          builder: (context, guardados, _) {
            final visibles = datos.$1.where(
              (fila) =>
                  (!_soloFavoritos || guardados.contains(fila['id'])) &&
                  (_categoria == null || fila['categoria_id'] == _categoria) &&
                  coincideBusqueda([
                    _titulo(fila),
                    dato(fila, 'nombre_cientifico'),
                    dato(fila, 'marca'),
                    dato(fila, 'modelo'),
                    dato(fila, 'resumen'),
                  ], _busqueda),
            );
            return ListaCliente(
              children: [
                ...widget.cabecera,
                EncabezadoApp(
                  titulo: switch (widget.tipo) {
                    TipoCatalogo.especies => 'Especies de peces',
                    TipoCatalogo.consejos => 'Consejos',
                    TipoCatalogo.equipo => 'Equipo de la tienda',
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (s) => setState(() => _busqueda = s),
                        decoration: const InputDecoration(
                          labelText: 'Buscar',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar',
                      onPressed: recargar,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                if (_consejos)
                  FilterChip(
                    label: const Text('Mis favoritos'),
                    selected: _soloFavoritos,
                    onSelected: (v) => setState(() {
                      _soloFavoritos = v;
                      if (v) _categoria = null;
                    }),
                  ),
                if (_consejos && datos.$2.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, limites) {
                      final ancho = limites.maxWidth < 265
                          ? limites.maxWidth
                          : (limites.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final categoria in datos.$2)
                            SizedBox(
                              width: ancho,
                              child: Semantics(
                                selected: _categoria == categoria['id'],
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: _categoria == categoria['id']
                                      ? Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHigh
                                      : null,
                                  child: InkWell(
                                    onTap: () => setState(() {
                                      _categoria = _categoria == categoria['id']
                                          ? null
                                          : categoria['id'] as String;
                                    }),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          ?_iconoCategoria(
                                            dato(categoria, 'nombre'),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              dato(categoria, 'nombre'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                else if (datos.$2.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: _categoria == null,
                        onSelected: (_) => setState(() => _categoria = null),
                      ),
                      for (final categoria in datos.$2)
                        ChoiceChip(
                          label: Text(dato(categoria, 'nombre')),
                          selected: _categoria == categoria['id'],
                          onSelected: (v) => setState(
                            () => _categoria = v
                                ? categoria['id'] as String
                                : null,
                          ),
                        ),
                    ],
                  ),
                if (visibles.isEmpty)
                  PanelEstadoApp(
                    tipo: TipoEstadoOperacion.vacio,
                    mensaje: _soloFavoritos
                        ? 'No hay consejos favoritos que mostrar.'
                        : (datos.$1.isEmpty
                              ? 'No hay contenido publicado.'
                              : 'No hay coincidencias.'),
                  ),
                for (final fila in visibles)
                  FichaCliente(
                    titulo: _titulo(fila),
                    foto: _foto(fila),
                    subtitulo: _consejos
                        ? dato(fila, 'resumen')
                        : _especies
                        ? dato(fila, 'nombre_cientifico')
                        : '${precioMx(fila['precio'])} · ${disponibilidad(fila)}',
                    alAbrir: () => _detalle(fila),
                    accion: _consejos
                        ? _botonFavorito(fila['id'] as String)
                        : null,
                  ),
              ],
            );
          },
        ),
  );
}

List<String> rutasProducto(FilaCliente producto) {
  final filas = List<FilaCliente>.from(
    producto['imagenes_productos'] as List? ?? [],
  );
  filas.sort((a, b) => (a['orden'] as int).compareTo(b['orden'] as int));
  return filas
      .map((fila) => dato(fila, 'ruta'))
      .where((ruta) => ruta.isNotEmpty)
      .toList();
}

String disponibilidad(FilaCliente producto) =>
    (producto['existencias'] as int) > 0 ? 'Disponible' : 'Agotado';

Widget? _iconoCategoria(String nombre) {
  final recurso = switch (nombre) {
    'Nudos' => 'nudos',
    'Técnicas' => 'tecnicas',
    'Equipo' => 'equipo',
    'Conservación' => 'conservacion',
    'Seguridad' => 'seguridad',
    _ => null,
  };
  return recurso == null
      ? null
      : SvgPicture.asset(
          'assets/consejos/$recurso.svg',
          width: 30,
          height: 30,
          excludeFromSemantics: true,
        );
}
