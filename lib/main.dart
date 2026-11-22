import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'compartido/servicios/almacen_sesion.dart';
import 'compartido/servicios/servicio_autenticacion.dart';
import 'modulos/autenticacion/control_acceso.dart';
import 'modulos/autenticacion/pantalla_login.dart';
import 'nucleo/tema_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const clave = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  const retornoWeb = String.fromEnvironment('SUPABASE_AUTH_REDIRECT_URL');
  const prefijoPublicable = 'sb_publishable_';
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      !clave.startsWith(prefijoPublicable) ||
      clave.length == prefijoPublicable.length) {
    runApp(const TarponMX());
    return;
  }

  try {
    final esMovil =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final destino = esMovil
        ? 'tharponmx://auth/callback'
        : (retornoWeb.isEmpty ? null : retornoWeb);
    final claveAnterior = 'sb-${uri.host.split('.').first}-auth-token';
    final almacen = AlmacenSesion(
      SharedPreferencesLocalStorage(persistSessionKey: '$claveAnterior-v2'),
      anterior: SharedPreferencesLocalStorage(persistSessionKey: claveAnterior),
    );
    final callback = destino == null ? null : Uri.parse(destino);
    final supabase = await Supabase.initialize(
      url: url,
      publishableKey: clave,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: almacen,
        pkceAsyncStorage: AlmacenVerificadorPkce(
          SharedPreferencesGotrueAsyncStorage(),
          almacen,
        ),
        detectSessionInUriPredicate: (enlace) {
          if (callback != null &&
              (enlace.scheme != callback.scheme ||
                  enlace.authority != callback.authority ||
                  enlace.path != callback.path)) {
            return false;
          }
          final query = enlace.queryParameters;
          final fragmento = Uri.splitQueryString(enlace.fragment);
          if (query.containsKey('access_token') ||
              fragmento.containsKey('access_token')) {
            return false;
          }
          return query.containsKey('code') ||
              query.containsKey('error') ||
              fragmento.containsKey('error');
        },
      ),
    );
    runApp(
      TarponMX(
        servicio: ServicioAutenticacion(
          supabase.client,
          redireccion: destino,
          almacen: almacen,
        ),
      ),
    );
  } catch (_) {
    runApp(
      const TarponMX(
        errorInicio:
            'No se pudo iniciar la autenticación. Reinicia la aplicación.',
      ),
    );
  }
}

class TarponMX extends StatelessWidget {
  const TarponMX({super.key, this.servicio, this.errorInicio});

  final ServicioAutenticacion? servicio;
  final String? errorInicio;

  @override
  Widget build(BuildContext context) {
    final autenticacion = servicio;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TemaApp.oscuro,
      home: autenticacion == null
          ? PantallaEstadoAcceso(
              mensaje: errorInicio ?? 'Configura SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY para continuar.',
            )
          : ControlAcceso(servicio: autenticacion),
    );
  }
}
