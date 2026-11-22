import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/estado_operacion.dart';
import '../autenticacion/pantalla_login.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key, this.perfil, this.cerrarSesion});

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  bool _ocupado = false;
  Object? _error;

  Future<void> _salir() async {
    try {
      final confirmado = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (context) => AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Quieres cerrar tu sesión en este dispositivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
      if (confirmado != true || !mounted) return;
      setState(() {
        _ocupado = true;
        _error = null;
      });
      await widget.cerrarSesion!();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted && _ocupado) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = widget.perfil;
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Perfil del Usuario', textAlign: TextAlign.center),
            if (perfil != null) ...[
              if (perfil.nombre.isNotEmpty)
                Text(perfil.nombre, textAlign: TextAlign.center),
              Text(
                perfil.rol == RolPerfil.admin ? 'Administrador' : 'Cliente',
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.cerrarSesion != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _ocupado ? null : _salir,
                child: const Text('Cerrar sesión'),
              ),
            ],
            if (_ocupado)
              const EstadoOperacion(
                tipo: TipoEstadoOperacion.carga,
                mensaje: 'Cerrando sesión…',
              )
            else if (error != null)
              EstadoOperacion(
                tipo: tipoErrorAcceso(error),
                mensaje: mensajeErrorAcceso(error),
              ),
          ],
        ),
      ),
    );
  }
}
