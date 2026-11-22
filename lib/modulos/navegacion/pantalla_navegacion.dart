import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/dialogo_cierre_sesion.dart';
import '../../compartido/widgets/encabezado_navegacion.dart';
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
  const PantallaNavegacion({super.key, this.perfil, this.cerrarSesion});

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  ModuloApp _modulo = ModuloApp.inicio;
  bool _promociones = false;

  void _seleccionar(ModuloApp modulo, {bool promociones = false}) {
    if (_modulo == modulo && _promociones == promociones) return;
    setState(() {
      _modulo = modulo;
      _promociones = promociones;
    });
  }

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPerfil(
          perfil: widget.perfil,
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
          onAbrirModulo: _seleccionar,
          onAbrirPromociones: () =>
              _seleccionar(ModuloApp.equipo, promociones: true),
        ),
        const PantallaEspecies(),
        const PantallaClima(),
        const PantallaMareas(),
        const PantallaMapa(),
        PantallaEquipamiento(mostrarPromociones: _promociones),
        const PantallaConsejos(),
      ],
    ),
  );
}
