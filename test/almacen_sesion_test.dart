import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tarpon_mx/compartido/servicios/almacen_sesion.dart';

void main() {
  test(
    'El verificador marca la sesión antes de intercambiar el código',
    () async {
      final disco = _DiscoPrueba();
      final almacen = AlmacenSesion(disco);
      await almacen.initialize();
      final datosPkce = _PkcePrueba();
      final pkce = AlmacenVerificadorPkce(datosPkce, almacen);
      const clave = 'sb-code-verifier';

      await pkce.setItem(key: clave, value: 'verificador/passwordRecovery');
      expect(almacen.recuperacionPendiente, isFalse);
      expect(await pkce.getItem(key: clave), 'verificador/passwordRecovery');
      await pkce.removeItem(key: clave);

      final antesDeGuardar = AlmacenSesion(disco);
      await antesDeGuardar.initialize();
      expect(antesDeGuardar.recuperacionPendiente, isTrue);
      expect(await antesDeGuardar.hasAccessToken(), isFalse);

      await almacen.persistSession('sesión simulada de recuperación');
      final restaurado = AlmacenSesion(disco);
      await restaurado.initialize();
      expect(restaurado.recuperacionPendiente, isTrue);
      expect(await restaurado.accessToken(), 'sesión simulada de recuperación');

      await restaurado.persistSession('sesión renovada');
      final renovado = AlmacenSesion(disco);
      await renovado.initialize();
      expect(renovado.recuperacionPendiente, isTrue);

      await renovado.removePersistedSession();
      final finalizado = AlmacenSesion(disco);
      await finalizado.initialize();
      expect(finalizado.recuperacionPendiente, isFalse);
      expect(await finalizado.hasAccessToken(), isFalse);
    },
  );

  test('La sesión anterior sin clasificación no se restaura', () async {
    final anterior = _DiscoPrueba()..valor = 'sesión sin clasificación';
    final disco = _DiscoPrueba();
    final almacen = AlmacenSesion(disco, anterior: anterior);
    await almacen.initialize();
    expect(await anterior.hasAccessToken(), isFalse);
    expect(await almacen.hasAccessToken(), isFalse);

    await almacen.persistSession('sesión normal');
    final restaurado = AlmacenSesion(disco);
    await restaurado.initialize();
    expect(await restaurado.accessToken(), 'sesión normal');
    expect(restaurado.recuperacionPendiente, isFalse);
  });
}

class _DiscoPrueba extends LocalStorage {
  String? valor;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => valor != null;
  @override
  Future<String?> accessToken() async => valor;
  @override
  Future<void> persistSession(String persistSessionString) async {
    valor = persistSessionString;
  }

  @override
  Future<void> removePersistedSession() async {
    valor = null;
  }
}

class _PkcePrueba extends GotrueAsyncStorage {
  final _datos = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _datos[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    _datos[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _datos.remove(key);
  }
}
