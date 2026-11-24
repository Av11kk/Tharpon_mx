import 'package:flutter/material.dart';

import '../../compartido/widgets/logo_tarpon.dart';
import '../../nucleo/tema_app.dart';

import 'package:flutter/services.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) =>
      const AnnotatedRegion<SystemUiOverlayStyle>(
        value: TemaApp.barraSistema,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: LogoTharpon(
                ancho: 240,
                alto: 150,
                variante: VarianteLogo.fondoOscuro,
              ),
            ),
          ),
        ),
      );
}
