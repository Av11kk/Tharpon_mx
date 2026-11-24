import 'package:supabase_flutter/supabase_flutter.dart';

import 'almacen_sesion.dart';

enum RolPerfil { cliente, admin }

class PerfilAutenticado {
  const PerfilAutenticado({
    required this.id,
    required this.nombre,
    required this.rol,
  });

  final String id;
  final String nombre;
  final RolPerfil rol;
}

class AccesoRestringido implements Exception {
  const AccesoRestringido();
}

class ServicioAutenticacion {
  ServicioAutenticacion(
    this._cliente, {
    this.redireccion,
    required this._almacen,
  });

  final SupabaseClient _cliente;
  final AlmacenSesion _almacen;
  final String? redireccion;

  Session? get sesion => _cliente.auth.currentSession;
  bool get recuperacionPendiente => _almacen.recuperacionPendiente;
  Stream<AuthState> get cambios => _cliente.auth.onAuthStateChange;

  Future<void> iniciarSesion(String correo, String contrasena) async {
    await _cliente.auth.signInWithPassword(email: correo, password: contrasena);
  }

  Future<bool> registrar(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    final respuesta = await _cliente.auth.signUp(
      email: correo,
      password: contrasena,
      data: {'nombre': nombre},
      emailRedirectTo: redireccion,
    );
    return respuesta.session != null;
  }

  Future<PerfilAutenticado> consultarPerfil(
    String id, {
    bool requiereAdmin = false,
  }) async {
    if (recuperacionPendiente || sesion?.user.id != id) {
      throw const AccesoRestringido();
    }
    final perfil = await _cliente
        .from('perfiles')
        .select('id,nombre,rol,activo')
        .eq('id', id)
        .maybeSingle();
    final rol = switch (perfil?['rol']) {
      'cliente' => RolPerfil.cliente,
      'admin' => RolPerfil.admin,
      _ => null,
    };
    if (perfil == null ||
        recuperacionPendiente ||
        sesion?.user.id != id ||
        perfil['activo'] != true ||
        rol == null ||
        (requiereAdmin && rol != RolPerfil.admin)) {
      throw const AccesoRestringido();
    }
    return PerfilAutenticado(
      id: id,
      nombre: perfil['nombre'] as String,
      rol: rol,
    );
  }

  Future<void> solicitarRecuperacion(String correo) =>
      _cliente.auth.resetPasswordForEmail(correo, redirectTo: redireccion);

  Future<void> cambiarContrasena(String contrasena) async {
    await _cliente.auth.updateUser(UserAttributes(password: contrasena));
  }

  Future<void> cerrarSesion() =>
      _cliente.auth.signOut(scope: SignOutScope.local);
}
