import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/dialogo_cierre_sesion.dart';
import '../../nucleo/medidas_app.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key, this.perfil, this.cerrarSesion});

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;

  @override
  Widget build(BuildContext context) {
    final perfil = this.perfil;
    final salir = cerrarSesion;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(MedidasApp.amplio),
          children: [
            const Text('Perfil del Usuario', textAlign: TextAlign.center),
            if (perfil != null) ...[
              if (perfil.nombre.isNotEmpty)
                Text(perfil.nombre, textAlign: TextAlign.center),
              Text(
                perfil.rol == RolPerfil.admin ? 'Administrador' : 'Cliente',
                textAlign: TextAlign.center,
              ),
            ],
            if (salir != null) ...[
              const SizedBox(height: MedidasApp.amplio),
              OutlinedButton(
                onPressed: () => confirmarCierreSesion(context, salir),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
