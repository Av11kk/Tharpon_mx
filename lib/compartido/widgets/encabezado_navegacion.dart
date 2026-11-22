import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';

class EncabezadoNavegacion extends StatelessWidget
    implements PreferredSizeWidget {
  const EncabezadoNavegacion({
    super.key,
    required this.abrirMenu,
    required this.abrirPerfil,
  });

  final VoidCallback abrirMenu, abrirPerfil;
  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: ColoresApp.fondo,
    toolbarHeight: preferredSize.height,
    titleSpacing: MedidasApp.margenPantalla,
    title: Row(
      children: [
        _AccionEncabezado(
          key: const Key('boton_menu'),
          etiqueta: 'Abrir menú',
          alPulsar: abrirMenu,
          icono: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 2,
                child: ColoredBox(color: ColoresApp.textoPrincipal),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 14,
                height: 2,
                child: ColoredBox(color: ColoresApp.textoPrincipal),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 20,
                height: 2,
                child: ColoredBox(color: ColoresApp.textoPrincipal),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedidasApp.pequeno),
            child: Text(
              'TARPON MX',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        _AccionEncabezado(
          key: const Key('boton_perfil'),
          etiqueta: 'Abrir perfil',
          alPulsar: abrirPerfil,
          circular: true,
          icono: SvgPicture.asset(
            'assets/inicio/perfil.svg',
            width: 46,
            height: 46,
            excludeFromSemantics: true,
          ),
        ),
      ],
    ),
  );
}

class _AccionEncabezado extends StatelessWidget {
  const _AccionEncabezado({
    super.key,
    required this.etiqueta,
    required this.alPulsar,
    required this.icono,
    this.circular = false,
  });

  final String etiqueta;
  final VoidCallback alPulsar;
  final Widget icono;
  final bool circular;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: etiqueta,
    onPressed: alPulsar,
    icon: icono,
    style: IconButton.styleFrom(
      backgroundColor: circular ? Colors.transparent : ColoresApp.tarjeta,
      padding: EdgeInsets.zero,
      fixedSize: const Size.square(MedidasApp.altoControl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(circular ? 48 : 16),
        side: circular
            ? BorderSide.none
            : const BorderSide(color: ColoresApp.bordeTarjetaAcceso),
      ),
    ),
  );
}
