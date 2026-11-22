import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import '../../nucleo/modulo_app.dart';

enum AccionMenu { perfil, cerrarSesion }

Future<Object?> abrirMenuNavegacion(
  BuildContext context, {
  required ModuloApp actual,
  required bool permiteCerrarSesion,
}) => showGeneralDialog<Object>(
  context: context,
  useRootNavigator: false,
  barrierDismissible: true,
  barrierLabel: 'Cerrar menú',
  barrierColor: const Color(0x73000000),
  transitionDuration: MovimientoApp.duracion(context, MovimientoApp.menu),
  transitionBuilder: (context, animacion, _, child) => SlideTransition(
    position: Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animacion,
        curve: MovimientoApp.salida,
        reverseCurve: MovimientoApp.entrada,
      ),
    ),
    child: child,
  ),
  pageBuilder: (context, _, _) =>
      _Menu(actual: actual, permiteCerrarSesion: permiteCerrarSesion),
);

class _Menu extends StatelessWidget {
  const _Menu({required this.actual, required this.permiteCerrarSesion});

  final ModuloApp actual;
  final bool permiteCerrarSesion;

  static const opciones = {
    ModuloApp.inicio: 'Inicio',
    ModuloApp.clima: 'Clima',
    ModuloApp.mareas: 'Mareas',
    ModuloApp.especies: 'Especies de peces',
    ModuloApp.mapa: 'Mapa',
    ModuloApp.consejos: 'Consejos',
    ModuloApp.equipo: 'Equipo',
  };

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 278,
        child: Material(
          key: const Key('menu_lateral'),
          color: ColoresApp.panelNavegacion,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(MedidasApp.amplio)),
            side: BorderSide(color: ColoresApp.bordeTarjetaAcceso),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MedidasApp.normal),
            child: LayoutBuilder(
              builder: (context, limites) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: limites.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TARPON MX',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    'Explora tu próxima aventura',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              key: const Key('cerrar_menu'),
                              tooltip: 'Cerrar menú',
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              style: IconButton.styleFrom(
                                backgroundColor: ColoresApp.accionSecundaria,
                                foregroundColor: ColoresApp.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        for (final opcion in opciones.entries) ...[
                          Semantics(
                            selected: actual == opcion.key,
                            child: TextButton(
                              key: Key('opcion_${opcion.key.name}'),
                              style: TextButton.styleFrom(
                                backgroundColor: actual == opcion.key
                                    ? ColoresApp.seleccionado
                                    : ColoresApp.opcionMenu,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(MedidasApp.radioControl),
                                  ),
                                ),
                                side: actual == opcion.key
                                    ? const BorderSide(color: ColoresApp.accion)
                                    : null,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context, opcion.key),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      opcion.value,
                                      style: actual == opcion.key
                                          ? null
                                          : Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: MedidasApp.pequeno),
                        ],
                        const Spacer(),
                        const Divider(color: ColoresApp.borde),
                        if (permiteCerrarSesion) ...[
                          TextButton(
                            key: const Key('menu_cerrar_sesion'),
                            style: TextButton.styleFrom(
                              backgroundColor: ColoresApp.accionSecundaria,
                              foregroundColor: ColoresApp.error,
                              alignment: AlignmentDirectional.centerStart,
                            ),
                            onPressed: () =>
                                Navigator.pop(context, AccionMenu.cerrarSesion),
                            child: const Text('Cerrar sesión'),
                          ),
                          const SizedBox(height: MedidasApp.normal),
                        ],
                        FilledButton(
                          key: const Key('menu_perfil'),
                          style: FilledButton.styleFrom(
                            alignment: AlignmentDirectional.centerStart,
                          ),
                          onPressed: () =>
                              Navigator.pop(context, AccionMenu.perfil),
                          child: const Text('Mi cuenta'),
                        ),
                        const SizedBox(height: MedidasApp.amplio),
                        Text(
                          'Tu comunidad de pesca',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
