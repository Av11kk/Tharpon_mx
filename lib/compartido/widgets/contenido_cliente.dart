import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show ClientException;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../servicios/repositorio_cliente.dart';
import '../../nucleo/medidas_app.dart';
import 'controles_app.dart';
import 'estado_operacion.dart';

String dato(FilaCliente fila, String campo) => fila[campo]?.toString() ?? '';
String fechaLocal(String fecha) {
  final local = DateTime.tryParse(fecha)?.toLocal();
  return local == null ? '' : '${local.day}/${local.month}/${local.year}';
}

bool coincideBusqueda(Iterable<String> valores, String busqueda) => valores.any(
  (valor) => valor.toLowerCase().contains(busqueda.trim().toLowerCase()),
);

void avisoCliente(BuildContext context, String mensaje) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));

Widget pantallaCliente(String titulo, Widget body) => Scaffold(
  appBar: AppBar(title: Text(titulo)),
  body: SafeArea(top: false, child: body),
);

Future<T?> abrirCliente<T>(BuildContext context, Widget pantalla) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => pantalla));

class ConsultaCliente<T> extends StatefulWidget {
  const ConsultaCliente({
    super.key,
    required this.cargar,
    required this.builder,
    this.cabecera,
  });
  final Future<T> Function() cargar;
  final Widget Function(BuildContext, T, VoidCallback) builder;
  final Widget? cabecera;

  @override
  State<ConsultaCliente<T>> createState() => _ConsultaClienteState<T>();
}

class _ConsultaClienteState<T> extends State<ConsultaCliente<T>> {
  late Future<T> _consulta = Future.sync(widget.cargar);
  void _recargar() {
    final consulta = Future<T>.sync(widget.cargar);
    setState(() {
      _consulta = consulta;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _consulta,
    builder: (context, estado) {
      if (estado.connectionState != ConnectionState.done) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(22),
            child: EstadoOperacion(
              tipo: TipoEstadoOperacion.carga,
              mensaje: 'Cargando información…',
            ),
          ),
        );
      }
      if (estado.hasError) {
        final error = estado.error;
        return ListView(
          padding: const EdgeInsets.all(22),
          children: [
            ?widget.cabecera,
            PanelEstadoApp(
              tipo:
                  error is ClientException ||
                      error is AuthRetryableFetchException
                  ? TipoEstadoOperacion.desconexion
                  : TipoEstadoOperacion.error,
              mensaje: 'No se pudo cargar la información.',
              acciones: [
                BotonSecundario(texto: 'Reintentar', alPulsar: _recargar),
              ],
            ),
          ],
        );
      }
      return widget.builder(context, estado.data as T, _recargar);
    },
  );
}

class ListaCliente extends StatelessWidget {
  const ListaCliente({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.fromLTRB(
      MedidasApp.margenPantalla,
      MedidasApp.margenPantalla,
      MedidasApp.margenPantalla,
      MedidasApp.margenPantalla + MediaQuery.paddingOf(context).bottom,
    ),
    itemCount: children.length,
    separatorBuilder: (_, _) => const SizedBox(height: MedidasApp.medio),
    itemBuilder: (_, i) => children[i],
  );
}

class FichaCliente extends StatelessWidget {
  const FichaCliente({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.foto,
    this.alAbrir,
    this.accion,
  });
  final String titulo;
  final String? subtitulo;
  final Widget? foto, accion;
  final VoidCallback? alAbrir;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      title: Text(titulo),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      leading: foto == null
          ? null
          : SizedBox.square(dimension: 54, child: foto),
      trailing:
          accion ?? (alAbrir == null ? null : const Icon(Icons.chevron_right)),
      onTap: alAbrir,
    ),
  );
}

class FotoCliente extends StatefulWidget {
  const FotoCliente({
    super.key,
    required this.repo,
    required this.ruta,
    this.personal = false,
  });
  final RepositorioCliente repo;
  final String ruta;
  final bool personal;
  @override
  State<FotoCliente> createState() => _FotoClienteState();
}

class _FotoClienteState extends State<FotoCliente> {
  late Future<String> _url = _firmar(false);
  bool _reintentado = false;

  Future<String> _firmar(bool renovar) => Future.sync(
    () => widget.repo.firmar(
      widget.ruta,
      personal: widget.personal,
      renovar: renovar,
    ),
  );

  @override
  void didUpdateWidget(covariant FotoCliente oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ruta != widget.ruta ||
        oldWidget.repo != widget.repo ||
        oldWidget.personal != widget.personal) {
      _reintentado = false;
      _url = _firmar(false);
    }
  }

  void _renovar() {
    _reintentado = true;
    final url = _firmar(true);
    setState(() {
      _url = url;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _url,
    builder: (context, estado) {
      if (estado.connectionState != ConnectionState.done) {
        return const Center(child: Icon(Icons.image_outlined));
      }
      if (estado.hasError) return _fallo();
      return Image.network(
        estado.requireData,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          if (!_reintentado) {
            final url = _url;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && identical(_url, url) && !_reintentado) _renovar();
            });
          }
          return _fallo();
        },
      );
    },
  );

  Widget _fallo() => Center(
    child: IconButton(
      tooltip: 'Reintentar imagen',
      onPressed: _renovar,
      icon: const Icon(Icons.broken_image_outlined),
    ),
  );
}

class EditorCliente extends StatefulWidget {
  const EditorCliente({
    super.key,
    required this.titulo,
    required this.campos,
    required this.guardar,
    this.foto = false,
    this.complemento,
  });
  final String titulo;
  final List<({String etiqueta, String inicial, bool requerido, int lineas})>
  campos;
  final Future<void> Function(List<String>, Uint8List?) guardar;
  final bool foto;
  final Widget? complemento;

  @override
  State<EditorCliente> createState() => _EditorClienteState();
}

class _EditorClienteState extends State<EditorCliente> {
  final _formulario = GlobalKey<FormState>();
  late final _campos = widget.campos
      .map((c) => TextEditingController(text: c.inicial))
      .toList();
  Uint8List? _foto;
  bool _ocupado = false;
  String? _error;

  @override
  void dispose() {
    for (final campo in _campos) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _seleccionar() async {
    setState(() => _ocupado = true);
    try {
      final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imagen == null || !mounted) return;
      if (await imagen.length() > 5242880) {
        throw const FormatException('La fotografía debe pesar hasta 5 MB.');
      }
      final bytes = await imagen.readAsBytes();
      if (formatoFoto(bytes) == null) {
        throw const FormatException('Selecciona una imagen JPG, PNG o WebP.');
      }
      if (mounted) {
        setState(() {
          _foto = bytes;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is FormatException
              ? error.message
              : 'No se pudo seleccionar la fotografía.',
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _guardar() async {
    if (_ocupado || !_formulario.currentState!.validate()) return;
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await widget.guardar(_campos.map((c) => c.text.trim()).toList(), _foto);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is FormatException
              ? error.message
              : 'No se pudo guardar. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => pantallaCliente(
    widget.titulo,
    PopScope(
      canPop: !_ocupado,
      child: Form(
        key: _formulario,
        child: ListaCliente(
          children: [
            ?widget.complemento,
            for (var i = 0; i < widget.campos.length; i++)
              TextFormField(
                controller: _campos[i],
                enabled: !_ocupado,
                maxLines: widget.campos[i].lineas,
                decoration: InputDecoration(
                  labelText: widget.campos[i].etiqueta,
                ),
                validator: (valor) =>
                    widget.campos[i].requerido &&
                        (valor?.trim().isEmpty ?? true)
                    ? 'Completa este campo.'
                    : null,
              ),
            if (widget.foto) ...[
              if (_foto case final foto?)
                SizedBox(
                  height: 160,
                  child: Image.memory(foto, fit: BoxFit.contain),
                ),
              BotonSecundario(
                texto: 'Seleccionar fotografía',
                alPulsar: _ocupado ? null : _seleccionar,
              ),
            ],
            if (_error case final error?)
              EstadoOperacion(tipo: TipoEstadoOperacion.error, mensaje: error),
            if (_ocupado)
              const EstadoOperacion(
                tipo: TipoEstadoOperacion.carga,
                mensaje: 'Procesando…',
              ),
            BotonPrincipal(
              texto: 'Guardar',
              alPulsar: _ocupado ? null : _guardar,
            ),
          ],
        ),
      ),
    ),
  );
}

({String etiqueta, String inicial, bool requerido, int lineas}) campoCliente(
  String etiqueta, {
  String inicial = '',
  bool requerido = false,
  int lineas = 1,
}) => (
  etiqueta: etiqueta,
  inicial: inicial,
  requerido: requerido,
  lineas: lineas,
);
