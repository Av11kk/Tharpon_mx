import 'package:flutter/material.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/catalogo_cliente.dart';

class PantallaConsejos extends StatelessWidget {
  const PantallaConsejos({super.key, this.repo});
  final RepositorioCliente? repo;
  @override
  Widget build(BuildContext context) => repo == null
      ? const Center(child: Text('Consejos'))
      : CatalogoCliente(repo: repo!, tipo: TipoCatalogo.consejos);
}
