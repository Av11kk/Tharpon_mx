import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../nucleo/colores_app.dart';

class EncabezadoNavegacion extends StatelessWidget
    implements PreferredSizeWidget {
  const EncabezadoNavegacion({
    super.key,
    required this.abrirZona,
    required this.abrirPerfil,
    required this.localidad,
  });
  final VoidCallback abrirZona, abrirPerfil;
  final String localidad;
  @override
  Size get preferredSize => const Size.fromHeight(68);
  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: ColoresApp.fondo,
    toolbarHeight: 68,
    titleSpacing: 12,
    title: TextButton.icon(
      key: const Key('boton_zona'),
      onPressed: abrirZona,
      icon: const Icon(
        Icons.location_on_outlined,
        size: 19,
        color: ColoresApp.acento,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TARPON MX',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: ColoresApp.etiqueta,
            ),
          ),
          Text(
            localidad,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textoPrincipal,
            ),
          ),
        ],
      ),
    ),
    actions: [
      IconButton(
        key: const Key('boton_perfil'),
        tooltip: 'Abrir perfil',
        onPressed: abrirPerfil,
        icon: SvgPicture.asset(
          'assets/inicio/perfil.svg',
          width: 42,
          height: 42,
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(width: 10),
    ],
  );
}
