import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Persiste juntos la sesión y el estado que impide abrir las rutas privadas.
class AlmacenSesion extends LocalStorage {
  AlmacenSesion(this._datos, {this._anterior});

  final LocalStorage _datos;
  final LocalStorage? _anterior;
  ({String? sesion, bool recuperacion}) _estado = (
    sesion: null,
    recuperacion: false,
  );
  Future<void> _cola = Future<void>.value();

  bool get recuperacionPendiente => _estado.recuperacion;

  @override
  Future<void> initialize() async {
    await _datos.initialize();
    final persistido = await _datos.accessToken();
    if (persistido != null) {
      final datos = jsonDecode(persistido) as Map<String, dynamic>;
      _estado = (
        sesion: datos['sesion'] as String?,
        recuperacion: datos['recuperacion'] as bool,
      );
    }
    // El formato anterior no distingue sesiones ordinarias y de recuperación.
    if (_anterior case final anterior?) {
      await anterior.initialize();
      if (await anterior.hasAccessToken()) {
        await anterior.removePersistedSession();
      }
    }
  }

  Future<void> _guardar({String? sesion, required bool recuperacion}) {
    final estado = (sesion: sesion, recuperacion: recuperacion);
    _estado = estado;
    final escritura = _cola.then((_) async {
      if (sesion == null && !recuperacion) {
        await _datos.removePersistedSession();
        return;
      }
      // Una sesión de recuperación difundida a otra pestaña conserva
      // la marca que se guardó antes del intercambio.
      final previo = recuperacion ? null : await _datos.accessToken();
      final pendiente =
          recuperacion ||
          (previo != null &&
              (jsonDecode(previo) as Map<String, dynamic>)['recuperacion'] ==
                  true);
      if (_estado == estado && pendiente) {
        _estado = (sesion: sesion, recuperacion: true);
      }
      await _datos.persistSession(
        jsonEncode({'sesion': sesion, 'recuperacion': pendiente}),
      );
    });
    // Un fallo de escritura no impide que las operaciones siguientes reintenten.
    _cola = escritura.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return escritura;
  }

  Future<void> iniciarRecuperacion() => _guardar(recuperacion: true);

  @override
  Future<bool> hasAccessToken() async => _estado.sesion != null;

  @override
  Future<String?> accessToken() async => _estado.sesion;

  @override
  Future<void> persistSession(String persistSessionString) => _guardar(
    sesion: persistSessionString,
    recuperacion: recuperacionPendiente,
  );

  @override
  Future<void> removePersistedSession() => _guardar(recuperacion: false);
}

/// GoTrue lee el verificador antes de intercambiar el código por una sesión.
/// El verificador de recuperación termina con el nombre del evento.
class AlmacenVerificadorPkce extends GotrueAsyncStorage {
  const AlmacenVerificadorPkce(this._datos, this._sesion);

  final GotrueAsyncStorage _datos;
  final AlmacenSesion _sesion;

  @override
  Future<String?> getItem({required String key}) async {
    final valor = await _datos.getItem(key: key);
    if (key.endsWith('-code-verifier') &&
        valor != null &&
        valor.endsWith('/${AuthChangeEvent.passwordRecovery.name}')) {
      await _sesion.iniciarRecuperacion();
    }
    return valor;
  }

  @override
  Future<void> setItem({required String key, required String value}) =>
      _datos.setItem(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _datos.removeItem(key: key);
}
