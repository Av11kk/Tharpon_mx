import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  bool _mostrarConsejo = false;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: const FHeader(title: Text('Tarpon')),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const Text('Pesca deportiva en Ciudad del Carmen'),
              const FCard(
                child: Text(
                  'Zona destacada: Laguna de Términos · datos de demostración',
                ),
              ),
              FButton(
                onPress: () =>
                    setState(() => _mostrarConsejo = !_mostrarConsejo),
                child: Text(
                  _mostrarConsejo ? 'Ocultar consejo' : 'Ver consejo',
                ),
              ),
              if (_mostrarConsejo)
                const Text('Consejo: revisa el clima antes de salir a pescar.'),
            ],
          ),
        ),
      ),
    );
  }
}
