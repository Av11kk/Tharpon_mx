import 'dart:async';

import 'package:flutter/material.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/catalogo_cliente.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/estado_operacion.dart';
import 'contacto_comercial.dart';

class PantallaEquipamiento extends StatefulWidget {
  const PantallaEquipamiento({
    super.key,
    this.mostrarPromociones = false,
    this.repo,
  });
  final bool mostrarPromociones;
  final RepositorioCliente? repo;

  @override
  State<PantallaEquipamiento> createState() => _PantallaEquipamientoState();
}

class _PantallaEquipamientoState extends State<PantallaEquipamiento> {
  late bool _ofertas = widget.mostrarPromociones;
  late final repo = widget.repo!;
  int _revision = 0;
  Timer? _vencimiento;
  Future<List<FilaCliente>>? _consultaOfertas;

  @override
  void dispose() {
    _vencimiento?.cancel();
    super.dispose();
  }

  Future<List<FilaCliente>> _cargarOfertas() async {
    final ofertas = await repo.promociones();
    if (mounted) _programarVencimiento(ofertas);
    return ofertas;
  }

  void _programarVencimiento(List<FilaCliente> ofertas) {
    _vencimiento?.cancel();
    final ahora = DateTime.now();
    final fechas =
        ofertas
            .where((fila) => promocionVigente(fila, ahora))
            .map((fila) => DateTime.parse(fila['fin'] as String))
            .toList()
          ..sort();
    if (fechas.isEmpty) return;
    _vencimiento = Timer(
      fechas.first.difference(ahora) + const Duration(milliseconds: 1),
      () {
        if (!mounted) return;
        setState(() {});
        _programarVencimiento(ofertas);
      },
    );
  }

  Future<List<FilaCliente>> _obtenerOfertas() async {
    final consulta = _consultaOfertas ??= _cargarOfertas();
    try {
      return await consulta;
    } catch (_) {
      if (identical(_consultaOfertas, consulta)) _consultaOfertas = null;
      rethrow;
    }
  }

  void _recargarOfertas() => setState(() {
    _consultaOfertas = null;
    _revision++;
  });

  @override
  void didUpdateWidget(covariant PantallaEquipamiento anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.mostrarPromociones != widget.mostrarPromociones) {
      _ofertas = widget.mostrarPromociones;
    }
  }

  void _contacto(
    ConsultaComercial tipo, {
    FilaCliente? producto,
    Object? precio,
  }) {
    final mensaje = mensajeComercial(
      tipo,
      nombre: producto == null ? null : dato(producto, 'nombre'),
      modelo: producto == null ? null : dato(producto, 'modelo'),
      precio: precio == null ? null : precioMx(precio),
    );
    abrirCliente<void>(
      context,
      pantallaCliente(
        'Vista previa de contacto',
        ConsultaCliente<String?>(
          cargar: repo.whatsapp,
          builder: (context, numero, _) =>
              ContactoComercial(telefono: numero, mensaje: mensaje),
        ),
      ),
    );
  }

  Widget _foto(String ruta) => FotoCliente(repo: repo, ruta: ruta);

  void _detalle(FilaCliente producto, {FilaCliente? promocion}) {
    if (promocion != null && !promocionVigente(promocion, DateTime.now())) {
      avisoCliente(context, 'La promoción ya no está vigente.');
      _recargarOfertas();
      return;
    }
    final nombre = dato(producto, 'nombre');
    final precio = producto['precio'];
    final oferta = promocion?['precio_oferta'];
    final banner = promocion?['banner_path'] as String?;
    abrirCliente<void>(
      context,
      DetalleCliente(
        titulo: promocion == null ? nombre : dato(promocion, 'titulo'),
        fotos: [
          if (banner != null && banner.isNotEmpty) _foto(banner),
          for (final ruta in rutasProducto(producto)) _foto(ruta),
        ],
        children: [
          if (promocion != null) Text(nombre),
          Text(
            oferta == null
                ? precioMx(precio)
                : '${precioMx(oferta)} · Antes ${precioMx(precio)}',
          ),
          if (promocion != null)
            Text(
              'Vigencia: ${fechaLocal(dato(promocion, 'inicio'))} – ${fechaLocal(dato(promocion, 'fin'))}',
            ),
          Chip(label: Text(disponibilidad(producto))),
          for (final (campo, etiqueta) in [
            ('marca', 'Marca'),
            ('modelo', 'Modelo'),
            ('descripcion', 'Descripción'),
          ])
            if (dato(producto, campo).isNotEmpty)
              FichaCliente(titulo: etiqueta, subtitulo: dato(producto, campo)),
          BotonPrincipal(
            texto: promocion == null
                ? 'Consultar por WhatsApp'
                : 'Consultar oferta por WhatsApp',
            alPulsar: () {
              if (promocion != null &&
                  !promocionVigente(promocion, DateTime.now())) {
                avisoCliente(context, 'La promoción ya no está vigente.');
                return;
              }
              _contacto(
                promocion == null
                    ? ConsultaComercial.producto
                    : ConsultaComercial.promocion,
                producto: producto,
                precio: oferta ?? precio,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _promociones({
    required bool carrusel,
  }) => ConsultaCliente<List<FilaCliente>>(
    key: ValueKey((carrusel, _revision)),
    cargar: _obtenerOfertas,
    builder: (context, filas, recargar) {
      final vigentes = filas
          .where((f) => promocionVigente(f, DateTime.now()))
          .toList();
      Widget tarjeta(FilaCliente fila) {
        final producto = FilaCliente.from(fila['productos'] as Map);
        final banner = fila['banner_path'] as String?;
        return FichaCliente(
          titulo: dato(fila, 'titulo'),
          subtitulo:
              '${precioMx(fila['precio_oferta'])} · ${disponibilidad(producto)}',
          foto: banner == null || banner.isEmpty ? null : _foto(banner),
          alAbrir: () => _detalle(producto, promocion: fila),
        );
      }

      if (carrusel) {
        if (vigentes.isEmpty) {
          return const Center(child: Text('Sin promociones vigentes'));
        }
        return PageView(children: vigentes.map(tarjeta).toList());
      }
      return ListaCliente(
        children: [
          BotonSecundario(
            texto: 'Volver al catálogo',
            alPulsar: () => setState(() => _ofertas = false),
          ),
          const EncabezadoApp(titulo: 'Todas las promociones'),
          TextButton(
            onPressed: _recargarOfertas,
            child: const Text('Actualizar'),
          ),
          if (vigentes.isEmpty)
            const PanelEstadoApp(
              tipo: TipoEstadoOperacion.vacio,
              mensaje: 'No hay promociones vigentes.',
            ),
          ...vigentes.map(tarjeta),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    if (widget.repo == null) {
      return Center(
        child: Text(
          widget.mostrarPromociones
              ? 'Las promociones aún no están disponibles en la app.'
              : 'Equipamiento Tarpon',
        ),
      );
    }
    return IndexedStack(
      index: _ofertas ? 1 : 0,
      children: [
        CatalogoCliente(
          repo: repo,
          tipo: TipoCatalogo.equipo,
          abrirProducto: _detalle,
          cabecera: [
            const EncabezadoApp(titulo: 'Promociones'),
            SizedBox(height: 125, child: _promociones(carrusel: true)),
            BotonSecundario(
              texto: 'Ver todas las promociones',
              alPulsar: () => setState(() => _ofertas = true),
            ),
            BotonSecundario(
              texto: 'Contacto comercial',
              alPulsar: () => _contacto(ConsultaComercial.general),
            ),
          ],
        ),
        if (_ofertas)
          _promociones(carrusel: false)
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
