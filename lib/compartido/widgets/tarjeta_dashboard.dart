import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import 'controles_app.dart';

class TarjetaDashboard extends StatelessWidget {
  const TarjetaDashboard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  final IconData icono;
  final String titulo, descripcion;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: MedidasApp.normal),
      child: TarjetaApp(
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: ColoresApp.superficie,
                borderRadius: BorderRadius.all(
                  Radius.circular(MedidasApp.radioControl),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(MedidasApp.medio),
                child: Icon(icono),
              ),
            ),
            const SizedBox(width: MedidasApp.normal),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo.toUpperCase(), style: texto.titleMedium),
                  const SizedBox(height: MedidasApp.pequeno),
                  Text(descripcion, style: texto.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
