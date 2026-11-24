import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';

enum VarianteLogo { original, fondoOscuro }

enum FormatoLogo { completo, compacto }

class LogoTharpon extends StatelessWidget {
  const LogoTharpon({
    super.key,
    this.ancho = 220,
    this.alto = 160,
    this.alineacion = Alignment.center,
    this.variante = VarianteLogo.original,
    this.formato = FormatoLogo.completo,
  });

  static const recurso = 'assets/logos/logo_tarpon.png';
  static const _proporcionOriginal = 1595 / 986;
  // Aquí termina el pez. El texto del PNG comienza debajo de este límite.
  static const _altoSimbolo = 0.53;

  final double ancho;
  final double alto;
  final Alignment alineacion;
  final VarianteLogo variante;
  final FormatoLogo formato;

  @override
  Widget build(BuildContext context) {
    final color = variante == VarianteLogo.fondoOscuro
        ? ColoresApp.textoPrincipal
        : null;
    Widget imagen({double? ancho, double? alto}) => Image.asset(
      recurso,
      semanticLabel: 'TARPON MX',
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      width: ancho,
      height: alto,
      alignment: alineacion,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_outlined),
    );
    if (formato == FormatoLogo.completo) {
      return imagen(ancho: ancho, alto: alto);
    }
    return SizedBox(
      width: ancho,
      height: alto,
      child: Align(
        alignment: alineacion,
        child: AspectRatio(
          aspectRatio: _proporcionOriginal / _altoSimbolo,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: AspectRatio(
                aspectRatio: _proporcionOriginal,
                child: imagen(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoTarpon extends LogoTharpon {
  const LogoTarpon({
    super.key,
    super.ancho,
    super.alto,
    super.alineacion,
    super.variante,
    super.formato,
  });
}
