import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import 'controles_app.dart';

enum TipoEstadoOperacion { carga, error, exito, desconexion, vacio }

class TransicionEstado extends StatelessWidget {
  const TransicionEstado({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MovimientoApp.duracion(context, MovimientoApp.pantalla),
    switchInCurve: MovimientoApp.salida,
    switchOutCurve: MovimientoApp.entrada,
    child: child,
  );
}

class AparicionApp extends StatelessWidget {
  const AparicionApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: MovimientoApp.pantalla,
      curve: MovimientoApp.salida,
      child: child,
      builder: (context, progreso, child) => FractionalTranslation(
        translation: MovimientoApp.recorrido * (1 - progreso),
        child: Opacity(opacity: progreso, child: child),
      ),
    );
  }
}

class EstadoOperacion extends StatelessWidget {
  const EstadoOperacion({super.key, required this.tipo, required this.mensaje});

  final TipoEstadoOperacion tipo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final (icono, color) = switch (tipo) {
      TipoEstadoOperacion.carga => (Icons.hourglass_empty, ColoresApp.etiqueta),
      TipoEstadoOperacion.error => (Icons.error_outline, ColoresApp.error),
      TipoEstadoOperacion.exito => (
        Icons.check_circle_outline,
        ColoresApp.exito,
      ),
      TipoEstadoOperacion.desconexion => (
        Icons.wifi_off_outlined,
        ColoresApp.etiqueta,
      ),
      TipoEstadoOperacion.vacio => (Icons.inbox_outlined, ColoresApp.etiqueta),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tipo == TipoEstadoOperacion.carga &&
              !MediaQuery.disableAnimationsOf(context))
            const SizedBox.square(
              dimension: MedidasApp.iconoCampo,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icono, color: color, size: MedidasApp.iconoCampo),
          const SizedBox(width: MedidasApp.pequeno),
          Expanded(child: Text(mensaje)),
        ],
      ),
    );
  }
}

class NotificacionApp extends StatelessWidget {
  const NotificacionApp({
    super.key,
    required this.tipo,
    required this.mensaje,
    this.titulo,
  });

  final TipoEstadoOperacion tipo;
  final String mensaje;
  final String? titulo;

  @override
  Widget build(BuildContext context) => TarjetaApp(
    radio: MedidasApp.radioDialogo,
    borde: ColoresApp.borde,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titulo case final titulo?) ...[
          Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: MedidasApp.pequeno),
        ],
        EstadoOperacion(tipo: tipo, mensaje: mensaje),
      ],
    ),
  );
}

class PanelEstadoApp extends StatelessWidget {
  const PanelEstadoApp({
    super.key,
    required this.tipo,
    required this.mensaje,
    this.acciones = const [],
  });

  final TipoEstadoOperacion tipo;
  final String mensaje;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final (titulo, recurso) = switch (tipo) {
      TipoEstadoOperacion.carga => ('Cargando información', 'carga'),
      TipoEstadoOperacion.error => ('No se pudo completar', 'error'),
      TipoEstadoOperacion.vacio => ('Sin registros', 'vacio'),
      TipoEstadoOperacion.desconexion => ('Sin conexión', 'desconexion'),
      TipoEstadoOperacion.exito => ('Operación completada', null),
    };
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MedidasApp.anchoEstado),
        child: TarjetaApp(
          radio: MedidasApp.radioEstado,
          borde: ColoresApp.borde,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recurso != null)
                Center(
                  child: SvgPicture.asset(
                    'assets/estados/$recurso.svg',
                    width: MedidasApp.ilustracionEstado.width,
                    height: MedidasApp.ilustracionEstado.height,
                    excludeFromSemantics: true,
                  ),
                ),
              Semantics(
                liveRegion: true,
                child: EncabezadoApp(titulo: titulo, descripcion: mensaje),
              ),
              if (acciones.isNotEmpty) ...[
                const SizedBox(height: MedidasApp.amplio),
                ...acciones,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class IndicadorRequisito extends StatelessWidget {
  const IndicadorRequisito({
    super.key,
    required this.texto,
    required this.cumplido,
    this.error = false,
  });

  final String texto;
  final bool cumplido, error;

  @override
  Widget build(BuildContext context) {
    final color = cumplido
        ? ColoresApp.exito
        : (error ? ColoresApp.error : ColoresApp.textoSecundario);
    final estado = cumplido
        ? 'Cumplido'
        : (error ? 'No coincide' : 'Pendiente');
    return Semantics(
      label: texto,
      value: estado,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              cumplido
                  ? Icons.check_circle_outline
                  : (error
                        ? Icons.error_outline
                        : Icons.radio_button_unchecked),
              size: 14,
              color: color,
            ),
            const SizedBox(width: MedidasApp.pequeno),
            Expanded(
              child: Text(
                texto,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
