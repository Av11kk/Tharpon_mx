import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';

class FondoAtmosferico extends StatelessWidget {
  const FondoAtmosferico({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: ColoresApp.fondo),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1, -.8),
              radius: 1.25,
              colors: [Color(0x3D587C92), Colors.transparent],
            ),
          ),
        ),
      ),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1, .5),
              radius: 1.1,
              colors: [Color(0x2D8DC8A4), Colors.transparent],
            ),
          ),
        ),
      ),
      const Positioned.fill(
        child: IgnorePointer(child: CustomPaint(painter: _OndasAtmosfera())),
      ),
      child,
    ],
  );
}

class _OndasAtmosfera extends CustomPainter {
  const _OndasAtmosfera();
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ColoresApp.etiqueta.withValues(alpha: .07);
    for (var linea = 0; linea < 5; linea++) {
      final trazo = Path();
      for (var x = 0.0; x <= size.width; x += 4) {
        final y =
            size.height * .35 +
            linea * 26 +
            math.sin(x / size.width * math.pi * 1.5 + linea * .2) * 45;
        if (x == 0) {
          trazo.moveTo(x, y);
        } else {
          trazo.lineTo(x, y);
        }
      }
      canvas.drawPath(trazo, pincel);
    }
  }

  @override
  bool shouldRepaint(_OndasAtmosfera oldDelegate) => false;
}
