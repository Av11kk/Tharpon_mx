import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

<<<<<<< HEAD
import 'compartido/servicios/almacen_sesion.dart';
import 'compartido/servicios/servicio_autenticacion.dart';
import 'modulos/autenticacion/control_acceso.dart';
import 'modulos/autenticacion/pantalla_login.dart';
import 'modulos/inicio/pantalla_bienvenida.dart';
import 'nucleo/tema_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
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

  runApp(
    TarponMX(
      inicializacion: _inicializar(url, clave, uri, retornoWeb),
      conectarDatos: true,
    ),
  );
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
    this.conectarDatos = false,
  });

  final ServicioAutenticacion? servicio;
  final String? errorInicio;
  final Future<ServicioAutenticacion>? inicializacion;
  final bool conectarDatos;

  @override
  Widget build(BuildContext context) {
    final autenticacion = servicio;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => LiquidGlassWidgets.wrap(
        brightnessResolver: Theme.maybeBrightnessOf,
        child: child!,
      ),
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
                  return ControlAcceso(
                    servicio: servicio,
                    cliente: conectarDatos ? Supabase.instance.client : null,
                  );
                }
                return const PantallaBienvenida();
              },
            )
          : autenticacion == null
          ? PantallaEstadoAcceso(
              mensaje: errorInicio ?? 'Configura SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY para continuar.',
            )
          : ControlAcceso(servicio: autenticacion),
=======
import 'package:forui/forui.dart';
import 'package:tharpom_mx/modulos/inicio/pantalla_inicio.dart';

void main() {
  runApp(const TarponApp());
}

class TarponApp extends StatelessWidget {
  const TarponApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.neutral.light.touch;

    return MaterialApp(
      title: 'Tarpon',

      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: const PantallaInicio(),
>>>>>>> c268b89c42e3fce6a2329e3909f014ebd7223ec9
    );
  }
}
