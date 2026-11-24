import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../servicios/servicio_geografico.dart';
import 'contenido_cliente.dart';
import 'controles_app.dart';
import 'estado_operacion.dart';
import 'grafica_condiciones.dart';

class EntornoGeo {
  EntornoGeo({RepositorioGeo? repositorio})
    : _http = repositorio == null ? http.Client() : null {
    if (repositorio != null) {
      repo = repositorio;
    } else {
      final cliente = ClienteGeo(_http!);
      final mareas = _https(const String.fromEnvironment('MAREAS_ENDPOINT'));
      repo = RepositorioGeo(
        cliente,
        mareas: mareas == null
            ? null
            : ProveedorMareasHttp(
                cliente,
                mareas,
                fuente: const String.fromEnvironment(
                  'MAREAS_FUENTE',
                  defaultValue: 'Proveedor de mareas configurado',
                ),
              ),
        pasarela: _https(const String.fromEnvironment('GEO_API_BASE')),
      );
    }
    clima = ValueNotifier(repo.clima(localidad.value));
    mar = ValueNotifier(repo.mar(costa.value));
    manejar(clima.value);
    manejar(mar.value);
    localidad.addListener(actualizarClima);
    costa.addListener(actualizarMar);
  }

  final http.Client? _http;
  static Uri? _https(String valor) {
    final uri = Uri.tryParse(valor);
    return uri != null &&
            uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty &&
            !uri.hasQuery &&
            !uri.hasFragment
        ? uri
        : null;
  }

  late final RepositorioGeo repo;
  final localidad = UbicacionManual();
  final costa = ValueNotifier(Localidad.carmen);
  late final ValueNotifier<Future<RespuestaGeo<PronosticoGeo>>> clima, mar;

  // Las pantallas consumen el error cuando se muestran.
  void manejar(Future<void> futuro) => futuro.ignore();

  bool _aplicando = false;

  /// Publica ambas selecciones antes de iniciar las consultas compartidas.
  void aplicarLocalidades(Localidad sitio, Localidad zonaCostera) {
    _aplicando = true;
    localidad.value = sitio;
    costa.value = zonaCostera;
    _aplicando = false;
    actualizarClima();
    actualizarMar();
  }

  void actualizarClima() {
    if (_aplicando) return;
    clima.value = repo.clima(localidad.value, renovar: true);
    manejar(clima.value);
  }

  void actualizarMar() {
    if (_aplicando) return;
    mar.value = repo.mar(costa.value, renovar: true);
    manejar(mar.value);
  }

  void dispose() {
    localidad.dispose();
    costa.dispose();
    clima.dispose();
    mar.dispose();
    _http?.close();
  }
}

class ConsultaGeo extends StatelessWidget {
  const ConsultaGeo({
    super.key,
    required this.consulta,
    required this.recargar,
    required this.builder,
    this.resumen = false,
  });
  final ValueNotifier<Future<RespuestaGeo<PronosticoGeo>>> consulta;
  final VoidCallback recargar;
  final Widget Function(RespuestaGeo<PronosticoGeo>) builder;
  final bool resumen;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: consulta,
    builder: (context, futuro, _) => FutureBuilder(
      future: futuro,
      builder: (context, estado) {
        if (estado.connectionState != ConnectionState.done) {
          return const Text('Consultando…');
        }
        if (estado.hasError) {
          return resumen
              ? const Text('Información no disponible')
              : PanelEstadoApp(
                  tipo:
                      estado.error is ErrorProveedor ||
                          estado.error is FormatException
                      ? TipoEstadoOperacion.error
                      : TipoEstadoOperacion.desconexion,
                  mensaje: 'El pronóstico no está disponible.',
                  acciones: [
                    BotonSecundario(texto: 'Reintentar', alPulsar: recargar),
                  ],
                );
        }
        final datos = estado.requireData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            _VigenciaGeo(
              key: ValueKey((datos.consultado, datos.desactualizado)),
              datos: datos,
            ),
            builder(datos),
          ],
        );
      },
    ),
  );
}

class _VigenciaGeo extends StatefulWidget {
  const _VigenciaGeo({super.key, required this.datos});
  final RespuestaGeo<PronosticoGeo> datos;

  @override
  State<_VigenciaGeo> createState() => _VigenciaGeoState();
}

class _VigenciaGeoState extends State<_VigenciaGeo> {
  Timer? _timer;
  late bool _vencido;

  @override
  void initState() {
    super.initState();
    final resta = widget.datos.consultado
        .add(const Duration(minutes: 15))
        .difference(DateTime.now());
    _vencido = widget.datos.desactualizado || resta <= Duration.zero;
    if (!_vencido) {
      _timer = Timer(resta, () => setState(() => _vencido = true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _vencido
      ? const Text('Datos anteriores · Actualiza para consultar de nuevo')
      : const SizedBox.shrink();
}

Future<Localidad?> elegirLocalidad(
  BuildContext context,
  EntornoGeo entorno, {
  bool gps = true,
}) => abrirCliente<Localidad>(
  context,
  _SelectorLocalidad(entorno: entorno, gps: gps),
);

class _SelectorLocalidad extends StatefulWidget {
  const _SelectorLocalidad({required this.entorno, required this.gps});
  final EntornoGeo entorno;
  final bool gps;

  @override
  State<_SelectorLocalidad> createState() => _SelectorLocalidadState();
}

class _SelectorLocalidadState extends State<_SelectorLocalidad> {
  final _busqueda = TextEditingController();
  Future<List<Localidad>>? _resultado;
  String? _error;
  bool _localizando = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  void _buscar() {
    final texto = _busqueda.text.trim();
    if (texto.length < 2) {
      setState(() => _error = 'Escribe al menos dos caracteres.');
      return;
    }
    final resultado = widget.entorno.repo.buscar(texto);
    setState(() {
      _error = null;
      _resultado = resultado;
    });
  }

  Future<void> _gps() async {
    setState(() => _localizando = true);
    try {
      final sitio = await widget.entorno.localidad.localizar();
      if (mounted) Navigator.pop(context, sitio);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is FormatException
              ? error.message
              : 'No se pudo obtener la ubicación.',
        );
      }
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  @override
  Widget build(BuildContext context) => pantallaCliente(
    widget.gps ? 'Elegir localidad' : 'Elegir zona costera',
    FutureBuilder<List<Localidad>>(
      future: _resultado,
      builder: (context, estado) => ListaCliente(
        children: [
          TextField(
            controller: _busqueda,
            onSubmitted: (_) => _buscar(),
            decoration: const InputDecoration(labelText: 'Buscar localidad'),
          ),
          BotonPrincipal(texto: 'Buscar', alPulsar: _buscar),
          if (widget.gps)
            BotonSecundario(
              texto: _localizando ? 'Localizando…' : 'Usar mi ubicación',
              alPulsar: _localizando ? null : _gps,
            ),
          FichaCliente(
            titulo: 'Ciudad del Carmen',
            alAbrir: () => Navigator.pop(context, Localidad.carmen),
          ),
          if (_error case final error?) Text(error),
          if (estado.connectionState == ConnectionState.waiting)
            const Text('Buscando…')
          else if (estado.hasError)
            const Text('No se pudo buscar. Vuelve a intentarlo.')
          else if (estado.hasData && estado.requireData.isEmpty)
            const Text('No se encontraron localidades.')
          else if (estado.hasData)
            for (final sitio in estado.requireData)
              FichaCliente(
                titulo: sitio.nombre,
                alAbrir: () => Navigator.pop(context, sitio),
              ),
        ],
      ),
    ),
  );
}

class GraficaGeo extends StatelessWidget {
  const GraficaGeo({
    super.key,
    required this.titulo,
    required this.pasos,
    required this.campo,
    required this.unidad,
  });
  final String titulo, campo, unidad;
  final List<PasoGeo> pasos;
  @override
  Widget build(BuildContext context) => GraficaCondiciones(
    titulo: titulo,
    pasos: pasos,
    campo: campo,
    unidad: unidad,
  );
}
