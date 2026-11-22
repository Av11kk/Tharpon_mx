import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'compartido/servicios/almacen_sesion.dart';
import 'compartido/servicios/servicio_autenticacion.dart';
import 'modulos/autenticacion/control_acceso.dart';
import 'modulos/autenticacion/pantalla_login.dart';
import 'modulos/inicio/pantalla_bienvenida.dart';
import 'nucleo/tema_app.dart';

void main() {
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

  runApp(TarponMX(inicializacion: _inicializar(url, clave, uri, retornoWeb)));
}

Future<ServicioAutenticacion> _inicializar(
  String url,
  String clave,
  Uri uri,
  String retornoWeb,
) async {
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
  return ServicioAutenticacion(
    supabase.client,
    redireccion: destino,
    almacen: almacen,
  );
}

class TarponMX extends StatelessWidget {
  const TarponMX({
    super.key,
    this.servicio,
    this.errorInicio,
    this.inicializacion,
  });

  final ServicioAutenticacion? servicio;
  final String? errorInicio;
  final Future<ServicioAutenticacion>? inicializacion;

  @override
  Widget build(BuildContext context) {
    final autenticacion = servicio;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TemaApp.oscuro,
      home: inicializacion != null
          ? FutureBuilder<ServicioAutenticacion>(
              future: inicializacion,
              builder: (context, resultado) {
                if (resultado.hasError) {
                  return const PantallaEstadoAcceso(
                    mensaje: 'No se pudo iniciar la autenticación. Reinicia la aplicación.',
                  );
                }
                if (resultado.data case final servicio?) {
                  return ControlAcceso(servicio: servicio);
                }
                return const PantallaBienvenida();
              },
            )
          : autenticacion == null
          ? PantallaEstadoAcceso(
              mensaje: errorInicio ?? 'Configura SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY para continuar.',
            )
          : ControlAcceso(servicio: autenticacion),
    );
  }
}
