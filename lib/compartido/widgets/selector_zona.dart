import 'package:flutter/material.dart';

import '../servicios/servicio_geografico.dart';
import 'panel_geografico.dart';
import 'superficie_cristal.dart';

Future<void> configurarZona(BuildContext context, EntornoGeo entorno) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF313A37),
      builder: (_) => _SelectorZona(entorno: entorno),
    );

class _SelectorZona extends StatefulWidget {
  const _SelectorZona({required this.entorno});
  final EntornoGeo entorno;
  @override
  State<_SelectorZona> createState() => _SelectorZonaState();
}

class _SelectorZonaState extends State<_SelectorZona> {
  late Localidad localidad = widget.entorno.localidad.value;
  late Localidad costa = widget.entorno.costa.value;
  late bool misma = localidad.coordenadas == costa.coordenadas;

  Future<void> _elegir(bool costera) async {
    final lugar = await elegirLocalidad(context, widget.entorno, gps: !costera);
    if (!mounted || lugar == null) return;
    setState(() {
      if (costera) {
        costa = lugar;
        misma = false;
      } else {
        localidad = lugar;
        if (misma) costa = lugar;
      }
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Center(child: Container(width: 40, height: 4, color: Colors.white24)),
        Text(
          'Tu zona de pesca',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Text(
          'Una sola selección para Inicio, Condiciones y sus detalles. Puedes usar una costa diferente si estás tierra adentro.',
        ),
        SuperficieCristal(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Localidad'),
                subtitle: Text(localidad.nombre),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _elegir(false),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Usar también para el mar'),
                value: misma,
                onChanged: (valor) => setState(() {
                  misma = valor;
                  if (valor) costa = localidad;
                }),
              ),
              if (!misma)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.waves),
                  title: const Text('Zona costera'),
                  subtitle: Text(costa.nombre),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _elegir(true),
                ),
            ],
          ),
        ),
        FilledButton.icon(
          key: const Key('aplicar_zona'),
          onPressed: () {
            widget.entorno.aplicarLocalidades(localidad, costa);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: const Text('Aplicar y actualizar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}
