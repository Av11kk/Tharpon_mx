import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/dialogo_cierre_sesion.dart';
import '../../compartido/widgets/encabezado_navegacion.dart';
import '../../compartido/widgets/panel_geografico.dart';
import '../../nucleo/modulo_app.dart';
import '../clima/pantalla_clima.dart';
import '../consejos/pantalla_consejos.dart';
import '../equipamiento/pantalla_equipamiento.dart';
import '../especies/pantalla_especies.dart';
import '../inicio/pantalla_inicio.dart';
import '../mapa/pantalla_mapa.dart';
import '../mareas/pantalla_mareas.dart';
import '../perfil/pantalla_perfil.dart';
import 'menu_navegacion.dart';

class PantallaNavegacion extends StatefulWidget {
  const PantallaNavegacion({
    super.key,
    this.perfil,
    this.cerrarSesion,
    this.cliente,
  });

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;
  final SupabaseClient? cliente;

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  ModuloApp _modulo = ModuloApp.inicio;
  bool _promociones = false;
  final _visitados = {ModuloApp.inicio, ModuloApp.clima};
  late final RepositorioCliente? _repo =
      widget.cliente == null || widget.perfil == null
      ? null
      : RepositorioCliente(widget.cliente!, widget.perfil!.id);
  late final _entorno = EntornoGeo();
  late final _puntos = ValueNotifier<Future<List<FilaCliente>>>(
    (_repo?.puntosPesca() ?? Future.value(<FilaCliente>[]))..ignore(),
  );

  @override
  void dispose() {
    _entorno.dispose();
    _puntos.dispose();
    super.dispose();
  }

  void _seleccionar(ModuloApp modulo, {bool promociones = false}) {
    if (_modulo == modulo && _promociones == promociones) return;
    setState(() {
      _modulo = modulo;
      _visitados.add(modulo);
      _promociones = promociones;
    });
  }

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPerfil(
          perfil: widget.perfil,
          repo: _repo,
          cerrarSesion: widget.cerrarSesion,
        ),
      ),
    );
  }

  Future<void> _abrirMenu() async {
    final cerrarSesion = widget.cerrarSesion;
    final opcion = await abrirMenuNavegacion(
      context,
      actual: _modulo,
      permiteCerrarSesion: cerrarSesion != null,
    );
    if (!mounted) return;
    switch (opcion) {
      case final ModuloApp modulo:
        _seleccionar(modulo);
      case AccionMenu.perfil:
        _abrirPerfil();
      case AccionMenu.cerrarSesion when cerrarSesion != null:
        await confirmarCierreSesion(context, cerrarSesion);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: EncabezadoNavegacion(
      abrirMenu: _abrirMenu,
      abrirPerfil: _abrirPerfil,
    ),
    body: IndexedStack(
      index: _modulo.index,
      children: [
        PantallaInicio(
          entorno: _entorno,
          puntos: _puntos,
          onAbrirModulo: _seleccionar,
          onAbrirPromociones: () =>
              _seleccionar(ModuloApp.equipo, promociones: true),
        ),
        if (_visitados.contains(ModuloApp.especies))
          PantallaEspecies(repo: _repo)
        else
          const SizedBox.shrink(),
        PantallaClima(entorno: _entorno),
        if (_visitados.contains(ModuloApp.mareas))
          PantallaMareas(entorno: _entorno)
        else
          const SizedBox.shrink(),
        if (_visitados.contains(ModuloApp.mapa))
          PantallaMapa(entorno: _entorno, puntos: _puntos, repo: _repo)
        else
          const SizedBox.shrink(),
        if (_visitados.contains(ModuloApp.equipo))
          PantallaEquipamiento(mostrarPromociones: _promociones, repo: _repo)
        else
          const SizedBox.shrink(),
        if (_visitados.contains(ModuloApp.consejos))
          PantallaConsejos(repo: _repo)
        else
          const SizedBox.shrink(),
      ],
    ),
  );
}
