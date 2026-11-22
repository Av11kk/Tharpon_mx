import 'package:flutter/material.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/estado_operacion.dart';

class PantallaCapturas extends StatelessWidget {
  const PantallaCapturas({super.key, required this.repo});
  final RepositorioCliente repo;

  @override
  Widget build(BuildContext context) =>
      PantallaArchivo(repo: repo, tipo: ArchivoCliente.capturas);
}

class PantallaArchivo extends StatefulWidget {
  const PantallaArchivo({super.key, required this.repo, required this.tipo});
  final RepositorioCliente repo;
  final ArchivoCliente tipo;

  @override
  State<PantallaArchivo> createState() => _PantallaArchivoState();
}

class _PantallaArchivoState extends State<PantallaArchivo> {
  String _busqueda = '';
  bool _recientes = true;
  bool get _capturas => widget.tipo == ArchivoCliente.capturas;
  bool get _reportes => widget.tipo == ArchivoCliente.reportes;
  String get _nombre => switch (widget.tipo) {
    ArchivoCliente.capturas => 'Mis capturas',
    ArchivoCliente.notas => 'Notas personales',
    ArchivoCliente.reportes => 'Mis reportes',
  };

  String _titulo(FilaCliente fila) =>
      _capturas ? _especie(fila) : dato(fila, 'titulo');

  Future<void> _editar(FilaCliente? fila, VoidCallback recargar) async {
    final repo = widget.repo;
    final anterior = fila ?? <String, dynamic>{};
    final id = fila?['id'] as String?;
    final pantalla = _capturas
        ? _EditorCaptura(repo: repo, fila: anterior)
        : EditorCliente(
            titulo: _reportes
                ? 'Crear reporte'
                : (id == null ? 'Nueva nota' : 'Editar nota'),
            campos: [
              campoCliente(
                'Título',
                inicial: dato(anterior, 'titulo'),
                requerido: true,
              ),
              campoCliente(
                _reportes ? 'Descripción' : 'Contenido',
                inicial: dato(anterior, 'contenido'),
                requerido: true,
                lineas: 5,
              ),
            ],
            guardar: (campos, _) => _reportes
                ? repo.crearReporte(campos[0], campos[1])
                : repo.guardarNota(campos[0], campos[1], id: id),
          );
    if (await abrirCliente<bool>(context, pantalla) == true && mounted) {
      recargar();
    }
  }

  Future<void> _borrar(FilaCliente fila, VoidCallback recargar) async {
    final confirmado = await confirmarAccion(
      context,
      titulo: 'Eliminar',
      mensaje: 'Esta acción es permanente.',
      accion: 'Eliminar',
      navegadorRaiz: false,
    );
    if (confirmado != true || !mounted) return;
    try {
      await widget.repo.borrar(widget.tipo, fila['id'] as String);
      if (mounted) recargar();
    } catch (_) {
      if (mounted) avisoCliente(context, 'No se pudo eliminar el registro.');
    }
  }

  void _detalle(FilaCliente fila) {
    final fecha = fechaLocal(dato(fila, widget.tipo.fecha));
    final foto = fila['foto_path'] as String?;
    abrirCliente<void>(
      context,
      pantallaCliente(
        _titulo(fila),
        ListaCliente(
          children: [
            if (fecha.isNotEmpty) Text(fecha),
            if (foto != null)
              SizedBox(
                height: 230,
                child: FotoCliente(
                  repo: widget.repo,
                  ruta: foto,
                  personal: true,
                ),
              ),
            if (_capturas) ...[
              for (final (campo, etiqueta) in [
                ('peso_kg', 'Peso (kg)'),
                ('longitud_cm', 'Longitud (cm)'),
                ('lugar', 'Lugar'),
                ('notas', 'Observaciones'),
              ])
                if (dato(fila, campo).isNotEmpty)
                  FichaCliente(titulo: etiqueta, subtitulo: dato(fila, campo)),
            ] else if (_reportes) ...[
              _EstadoReporte(estado: dato(fila, 'estado')),
              Text(dato(fila, 'descripcion')),
              if (dato(fila, 'respuesta').isNotEmpty)
                FichaCliente(
                  titulo: 'Respuesta administrativa',
                  subtitulo: dato(fila, 'respuesta'),
                ),
            ] else
              Text(dato(fila, 'contenido')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => pantallaCliente(
    _nombre,
    ConsultaCliente(
      cargar: () => widget.repo.archivos(widget.tipo),
      builder: (context, List<FilaCliente> datos, recargar) {
        final filas = (_recientes ? datos : datos.reversed).where(
          (fila) => coincideBusqueda([
            _titulo(fila),
            dato(fila, 'contenido'),
            dato(fila, 'lugar'),
            dato(fila, 'descripcion'),
            dato(fila, 'notas'),
          ], _busqueda),
        );
        return ListaCliente(
          children: [
            BotonPrincipal(
              texto: _capturas
                  ? 'Registrar nueva captura'
                  : (_reportes ? 'Crear reporte' : 'Nueva nota'),
              alPulsar: () => _editar(null, recargar),
              icono: Icons.add,
            ),
            TextField(
              onChanged: (valor) => setState(() => _busqueda = valor),
              decoration: const InputDecoration(labelText: 'Buscar'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _recientes
                        ? 'Más recientes primero'
                        : 'Más antiguos primero',
                  ),
                ),
                IconButton(
                  tooltip: 'Cambiar orden',
                  onPressed: () => setState(() => _recientes = !_recientes),
                  icon: const Icon(Icons.swap_vert),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: recargar,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (filas.isEmpty)
              PanelEstadoApp(
                tipo: TipoEstadoOperacion.vacio,
                mensaje: datos.isEmpty
                    ? 'Aún no tienes registros.'
                    : 'No hay coincidencias.',
              ),
            for (final fila in filas)
              FichaCliente(
                titulo: _titulo(fila),
                subtitulo: fechaLocal(dato(fila, widget.tipo.fecha)),
                alAbrir: () => _detalle(fila),
                accion: _reportes
                    ? _EstadoReporte(estado: dato(fila, 'estado'))
                    : PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        onSelected: (opcion) => opcion == 'editar'
                            ? _editar(fila, recargar)
                            : _borrar(fila, recargar),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'borrar',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
              ),
          ],
        );
      },
    ),
  );
}

class _EstadoReporte extends StatelessWidget {
  const _EstadoReporte({required this.estado});
  final String estado;
  @override
  Widget build(BuildContext context) {
    final (texto, icono) = switch (estado) {
      'en_revision' => ('En revisión', Icons.visibility_outlined),
      'resuelto' => ('Resuelto', Icons.check_circle_outline),
      _ => ('Pendiente', Icons.schedule),
    };
    return Chip(avatar: Icon(icono, size: 16), label: Text(texto));
  }
}

String _especie(FilaCliente fila) =>
    (fila['especies'] as Map?)?['nombre']?.toString() ??
    fila['especie_texto']?.toString() ??
    'Especie sin identificar';

double? medidaCaptura(String texto) {
  if (texto.trim().isEmpty) return null;
  final valor = double.tryParse(texto.trim().replaceAll(',', '.'));
  if (valor == null || !valor.isFinite || valor < 0) {
    throw const FormatException(
      'Peso y longitud deben ser números no negativos.',
    );
  }
  return valor;
}

class _EditorCaptura extends StatefulWidget {
  const _EditorCaptura({required this.repo, required this.fila});
  final RepositorioCliente repo;
  final FilaCliente fila;
  @override
  State<_EditorCaptura> createState() => _EditorCapturaState();
}

class _EditorCapturaState extends State<_EditorCaptura> {
  late DateTime _fecha =
      DateTime.tryParse(dato(widget.fila, 'fecha'))?.toLocal() ??
      DateTime.now();
  late String? _especieId = widget.fila['especie_id'] as String?;
  late Future<List<FilaCliente>> _especies = widget.repo.especies();

  Future<void> _cambiarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(ahora),
      initialDate: _fecha.isAfter(ahora) ? ahora : _fecha,
    );
    if (fecha != null && mounted) setState(() => _fecha = fecha);
  }

  @override
  Widget build(BuildContext context) => EditorCliente(
    titulo: widget.fila.isEmpty ? 'Agregar captura' : 'Editar captura',
    foto: true,
    complemento: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
          future: _especies,
          builder: (context, estado) {
            if (!estado.hasData) {
              return TextButton(
                onPressed: estado.hasError
                    ? () {
                        final especies = widget.repo.especies();
                        setState(() {
                          _especies = especies;
                        });
                      }
                    : null,
                child: Text(
                  estado.hasError
                      ? 'Reintentar catálogo de especies'
                      : 'Cargando especies…',
                ),
              );
            }
            final filas = estado.requireData;
            return DropdownButton<String>(
              isExpanded: true,
              value: filas.any((f) => f['id'] == _especieId) ? _especieId : '',
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Escribir especie'),
                ),
                for (final fila in filas)
                  DropdownMenuItem(
                    value: fila['id'] as String,
                    child: Text(dato(fila, 'nombre')),
                  ),
              ],
              onChanged: (id) =>
                  setState(() => _especieId = id?.isEmpty == true ? null : id),
            );
          },
        ),
        TextButton(
          onPressed: _cambiarFecha,
          child: Text('Fecha: ${fechaLocal(_fecha.toIso8601String())}'),
        ),
      ],
    ),
    campos: [
      campoCliente(
        'Especie (texto libre)',
        inicial: dato(widget.fila, 'especie_texto'),
      ),
      campoCliente('Peso (kg)', inicial: dato(widget.fila, 'peso_kg')),
      campoCliente('Longitud (cm)', inicial: dato(widget.fila, 'longitud_cm')),
      campoCliente('Lugar', inicial: dato(widget.fila, 'lugar')),
      campoCliente(
        'Observaciones',
        inicial: dato(widget.fila, 'notas'),
        lineas: 4,
      ),
    ],
    guardar: (campos, foto) {
      if (_fecha.isAfter(DateTime.now())) {
        throw const FormatException('La fecha no puede ser futura.');
      }
      if (_especieId == null && campos[0].isEmpty) {
        throw const FormatException('Selecciona o escribe la especie.');
      }
      return widget.repo.guardarCaptura(
        {
          'especie_id': _especieId,
          'especie_texto': campos[0].isEmpty ? null : campos[0],
          'fecha': _fecha.toUtc().toIso8601String(),
          'peso_kg': medidaCaptura(campos[1]),
          'longitud_cm': medidaCaptura(campos[2]),
          'lugar': campos[3],
          'notas': campos[4],
        },
        id: widget.fila['id'] as String?,
        foto: foto,
        anterior: widget.fila['foto_path'] as String?,
      );
    },
  );
}
