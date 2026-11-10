import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:tharpom_mx/modulos/inicio/pantalla_inicio.dart';

void main() {
  runApp(const TarponApp());
}

class TarponApp extends StatelessWidget {
  const TarponApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.neutral.light.touch;

    return MaterialApp(
      title: 'Tarpon',

      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: const PantallaInicio(),
    );
  }
}
