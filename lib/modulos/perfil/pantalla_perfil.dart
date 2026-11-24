import 'package:flutter/material.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';
import '../../compartido/widgets/dialogo_cierre_sesion.dart';
import '../capturas/pantalla_capturas.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key, this.perfil, this.cerrarSesion, this.repo});
  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;
  final RepositorioCliente? repo;

  Widget _salir(BuildContext context, Future<void> Function() salir) =>
      OutlinedButton(
        onPressed: () => confirmarCierreSesion(context, salir),
        child: const Text('Cerrar sesión'),
      );

  @override
  Widget build(BuildContext context) {
    final repo = this.repo;
    final salir = cerrarSesion;
    return pantallaCliente(
      'Perfil',
      repo == null
          ? ListaCliente(
              children: [
                const Text('Perfil del Usuario', textAlign: TextAlign.center),
                if (perfil case final perfil?) ...[
                  Text(perfil.nombre, textAlign: TextAlign.center),
                  Text(
                    perfil.rol == RolPerfil.admin ? 'Administrador' : 'Cliente',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (salir != null) _salir(context, salir),
              ],
            )
          : ConsultaCliente<FilaCliente>(
              cargar: repo.perfil,
              cabecera: salir == null ? null : _salir(context, salir),
              builder: (context, fila, recargar) {
                final avatar = fila['avatar_path'] as String?;
                return ListaCliente(
                  children: [
                    const EncabezadoApp(
                      titulo: 'Mi cuenta',
                      descripcion: 'Perfil del Usuario',
                    ),
                    if (avatar != null)
                      Center(
                        child: ClipOval(
                          child: SizedBox.square(
                            dimension: 100,
                            child: FotoCliente(
                              repo: repo,
                              ruta: avatar,
                              personal: true,
                            ),
                          ),
                        ),
                      ),
                    FichaCliente(
                      titulo: dato(fila, 'nombre').isEmpty
                          ? 'Sin nombre'
                          : dato(fila, 'nombre'),
                      subtitulo: [
                        repo.correo ?? '',
                        fila['rol'] == 'admin' ? 'Administrador' : 'Cliente',
                      ].join('\n'),
                    ),
                    BotonSecundario(
                      texto: 'Editar perfil',
                      alPulsar: () async {
                        final cambio = await abrirCliente<bool>(
                          context,
                          EditorCliente(
                            titulo: 'Editar perfil',
                            foto: true,
                            campos: [
                              campoCliente(
                                'Nombre',
                                inicial: dato(fila, 'nombre'),
                                requerido: true,
                              ),
                            ],
                            complemento: Text(repo.correo ?? ''),
                            guardar: (campos, foto) {
                              if (campos[0].runes.length > 120) {
                                throw const FormatException(
                                  'Usa hasta 120 caracteres.',
                                );
                              }
                              return repo.guardarPerfil(
                                campos[0],
                                foto: foto,
                                anterior: avatar,
                              );
                            },
                          ),
                        );
                        if (context.mounted && cambio == true) recargar();
                      },
                    ),
                    FichaCliente(
                      titulo: 'Mis capturas',
                      alAbrir: () => abrirCliente<void>(
                        context,
                        PantallaCapturas(repo: repo),
                      ),
                    ),
                    FichaCliente(
                      titulo: 'Notas personales',
                      alAbrir: () => abrirCliente<void>(
                        context,
                        PantallaArchivo(repo: repo, tipo: ArchivoCliente.notas),
                      ),
                    ),
                    FichaCliente(
                      titulo: 'Mis reportes',
                      alAbrir: () => abrirCliente<void>(
                        context,
                        PantallaArchivo(
                          repo: repo,
                          tipo: ArchivoCliente.reportes,
                        ),
                      ),
                    ),
                    if (salir != null) _salir(context, salir),
                  ],
                );
              },
            ),
    );
  }
}
