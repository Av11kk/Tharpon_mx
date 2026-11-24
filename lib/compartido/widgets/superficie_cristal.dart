import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../nucleo/colores_app.dart';

/// Un solo material óptico para tarjetas y controles flotantes.
class SuperficieCristal extends StatelessWidget {
  const SuperficieCristal({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radio = 24,
    this.premium = false,
    this.borde,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radio;
  final bool premium;
  final Color? borde;

  static const material = LiquidGlassSettings(
    glassColor: Color(0x0DA9D3D9),
    bodyMode: GlassBodyMode.clear,
    blur: 40,
    thickness: 22,
    refractiveIndex: 1.12,
    saturation: 1.05,
    lightIntensity: .6,
    chromaticAberration: .006,
    rimLight: .2,
  );

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.highContrastOf(context)) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: ColoresApp.tarjeta,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: ColoresApp.etiqueta),
        ),
        child: child,
      );
    }
    final cristal = GlassContainer(
      shape: LiquidRoundedSuperellipse(borderRadius: radio),
      settings: material,
      useOwnLayer: true,
      quality: premium ? GlassQuality.premium : GlassQuality.standard,
      padding: padding,
      child: child,
    );
    if (borde == null) return cristal;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(color: borde!),
        ),
      ),
      child: cristal,
    );
  }
}

class EntradaCristal extends StatelessWidget {
  const EntradaCristal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : child
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: .025, end: 0, curve: Curves.easeOutCubic);
}
