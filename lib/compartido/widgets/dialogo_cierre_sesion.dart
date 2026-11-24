import 'package:flutter/material.dart';

import '../../modulos/autenticacion/pantalla_login.dart';
import '../../nucleo/medidas_app.dart';
import 'controles_app.dart';
import 'estado_operacion.dart';

Future<void> confirmarCierreSesion(
  BuildContext context,
  Future<void> Function() cerrarSesion,
) => showDialog<void>(
  context: context,
  useRootNavigator: false,
  barrierDismissible: false,
  animationStyle: AnimationStyle(
    duration: MovimientoApp.duracion(context, MovimientoApp.dialogo),
    curve: MovimientoApp.salida,
  ),
  builder: (_) => _DialogoCierre(cerrarSesion: cerrarSesion),
);

class _DialogoCierre extends StatefulWidget {
  const _DialogoCierre({required this.cerrarSesion});
  final Future<void> Function() cerrarSesion;

  @override
  State<_DialogoCierre> createState() => _DialogoCierreState();
}

class _DialogoCierreState extends State<_DialogoCierre> {
  bool _ocupado = false;
  Object? _error;

  Future<void> _confirmar() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await widget.cerrarSesion();
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_ocupado,
    child: Dialog(
      constraints: const BoxConstraints(maxWidth: 340),
      insetPadding: const EdgeInsets.all(MedidasApp.amplio),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MedidasApp.interiorTarjeta),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EncabezadoApp(titulo: 'Cerrar sesión'),
            const SizedBox(height: MedidasApp.normal),
            const Text('¿Deseas salir de tu cuenta?'),
            const SizedBox(height: MedidasApp.pequeno),
            Text(
              'Tus capturas y notas se conservarán.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_ocupado || _error != null) ...[
              const SizedBox(height: MedidasApp.normal),
              EstadoOperacion(
                tipo: _ocupado
                    ? TipoEstadoOperacion.carga
                    : tipoErrorAcceso(_error!),
                mensaje: _ocupado
                    ? 'Cerrando sesión…'
                    : mensajeErrorAcceso(_error!),
              ),
            ],
            const SizedBox(height: 42),
            OverflowBar(
              spacing: MedidasApp.medio,
              overflowSpacing: MedidasApp.pequeno,
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                BotonSecundario(
                  texto: 'Cancelar',
                  alPulsar: _ocupado ? null : () => Navigator.pop(context),
                ),
                BotonPrincipal(
                  texto: 'Cerrar sesión',
                  alPulsar: _ocupado ? null : _confirmar,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
