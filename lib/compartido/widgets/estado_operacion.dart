import 'package:flutter/material.dart';

enum TipoEstadoOperacion { carga, error, exito, desconexion }

class TransicionEstado extends StatelessWidget {
  const TransicionEstado({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      child: child,
    );
  }
}

class EstadoOperacion extends StatelessWidget {
  const EstadoOperacion({super.key, required this.tipo, required this.mensaje});

  final TipoEstadoOperacion tipo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final icono = switch (tipo) {
      TipoEstadoOperacion.carga => Icons.hourglass_empty,
      TipoEstadoOperacion.error => Icons.error_outline,
      TipoEstadoOperacion.exito => Icons.check_circle_outline,
      TipoEstadoOperacion.desconexion => Icons.wifi_off_outlined,
    };
    final animar = !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tipo == TipoEstadoOperacion.carga && animar)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icono, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(mensaje)),
        ],
      ),
    );
  }
}
