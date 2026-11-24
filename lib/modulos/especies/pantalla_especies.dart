import 'package:flutter/material.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/catalogo_cliente.dart';

class PantallaEspecies extends StatelessWidget {
  const PantallaEspecies({super.key, this.repo});
  final RepositorioCliente? repo;
  @override
  Widget build(BuildContext context) => repo == null
      ? const Center(child: Text('Especies de peces'))
      : CatalogoCliente(repo: repo!, tipo: TipoCatalogo.especies);
}
