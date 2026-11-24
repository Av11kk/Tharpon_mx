import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Aplicación principal de Tarpon MX.
import 'package:tarpon_mx/compartido/servicios/servicio_autenticacion.dart';
import 'package:tarpon_mx/compartido/widgets/logo_tarpon.dart';
import 'package:tarpon_mx/compartido/widgets/estado_operacion.dart';
import 'package:tarpon_mx/main.dart';
import 'package:tarpon_mx/nucleo/colores_app.dart';

// Pantalla utilizada para verificar la navegación.
import 'package:tarpon_mx/modulos/condiciones/pantalla_condiciones.dart';
import 'package:tarpon_mx/modulos/inicio/pantalla_bienvenida.dart';

/// =====================================================
/// PRUEBAS AUTOMATIZADAS DE TARPON MX
/// =====================================================
///
/// Estas pruebas comprueban:
///
/// 1. Que la aplicación inicia.
/// 2. Que solo existe una barra superior.
/// 3. Que el menú contiene los siete módulos.
/// 4. Que el banner Clima abre su pantalla.
/// 5. Que el botón de Perfil abre su apartado.
///
/// Las pruebas no dependen de que una API
/// meteorológica responda correctamente.

void main() {
  Future<_AutenticacionPrueba> abrirApp(
    WidgetTester tester, {
    bool conSesion = true,
    RolPerfil rol = RolPerfil.cliente,
  }) async {
    final servicio = _AutenticacionPrueba(conSesion: conSesion, rol: rol);
    addTearDown(servicio.eventos.close);
    await tester.pumpWidget(TarponMX(servicio: servicio));
    await tester.pumpAndSettle();
    return servicio;
  }

  testWidgets('Bienvenida espera la inicialización real y respeta el acceso', (
    tester,
  ) async {
    final inicializacion = Completer<ServicioAutenticacion>();
    final servicio = _AutenticacionPrueba(
      conSesion: false,
      rol: RolPerfil.cliente,
    );
    addTearDown(servicio.eventos.close);
    await tester.pumpWidget(TarponMX(inicializacion: inicializacion.future));
    expect(find.byType(PantallaBienvenida), findsOneWidget);
    expect(find.byKey(const Key('boton_menu')), findsNothing);
    inicializacion.complete(servicio);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaBienvenida), findsNothing);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('La barra inferior reemplaza el menú y abre Condiciones', (
    tester,
  ) async {
    await abrirApp(tester);
    expect(find.byKey(const Key('boton_menu')), findsNothing);
    await tester.tapAt(tester.getCenter(find.text('Condiciones').last));
    await tester.pumpAndSettle();
    expect(find.text('CIELO + MAR'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    await tester.tapAt(tester.getCenter(find.text('Explorar').last));
    await tester.pumpAndSettle();
    expect(find.text('Especies de peces'), findsOneWidget);
    expect(find.text('Consejos'), findsOneWidget);
  });

  testWidgets('Perfil y cierre funcionan en una pantalla pequeña', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final servicio = await abrirApp(tester);
    Future<void> abrirCierre() async {
      if (find.text('Perfil del Usuario').evaluate().isEmpty) {
        await tester.tap(find.byKey(const Key('boton_perfil')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
      await tester.pumpAndSettle();
    }

    await abrirCierre();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(servicio.sesion, isNotNull);
    expect(find.text('Perfil del Usuario'), findsOneWidget);
    await abrirCierre();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(
      find.byKey(const Key('boton_menu'), skipOffstage: false),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Desde Inicio se abre Promociones sin inventar un catálogo', (
    tester,
  ) async {
    await abrirApp(tester);
    final scroll = find.descendant(
      of: find.byType(RefreshIndicator),
      matching: find.byType(Scrollable),
    );
    final promociones = find.byKey(const Key('banner_promociones'));
    await tester.scrollUntilVisible(promociones, 200, scrollable: scroll);
    await tester.tap(promociones);
    await tester.pumpAndSettle();
    expect(
      find.text('Las promociones aún no están disponibles en la app.'),
      findsOneWidget,
    );
  });

  testWidgets('Sin sesión abre el acceso y permite registrarse', (
    tester,
  ) async {
    final servicio = await abrirApp(tester, conSesion: false);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.byKey(const Key('boton_menu')), findsNothing);

    final registro = find.text('¿No tienes cuenta? Regístrate');
    await tester.ensureVisible(registro);
    await tester.tap(registro);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));

    final campos = find.byType(TextFormField);
    for (final (indice, valor) in [
      (0, 'Persona de prueba'),
      (1, 'cliente@example.com'),
      (2, 'clave123'),
      (3, 'clave123'),
    ]) {
      await tester.ensureVisible(campos.at(indice));
      await tester.enterText(campos.at(indice), valor);
    }
    final crear = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(crear).onPressed, isNull);
    expect(
      tester
          .widgetList<IndicadorRequisito>(find.byType(IndicadorRequisito))
          .any((regla) => !regla.cumplido),
      isTrue,
    );
    expect(servicio.registros, 0);

    await tester.enterText(campos.at(2), 'Clave123!');
    await tester.pump();
    final requisitos = tester.widgetList<IndicadorRequisito>(
      find.byType(IndicadorRequisito),
    );
    expect(requisitos.where((regla) => regla.cumplido), hasLength(5));
    expect(
      requisitos.singleWhere((regla) => regla.error).texto,
      'Las contraseñas coinciden',
    );
    expect(tester.widget<FilledButton>(crear).onPressed, isNull);
    expect(servicio.registros, 0);

    await tester.enterText(campos.at(3), 'Clave123!');
    await tester.pump();
    expect(
      tester
          .widgetList<IndicadorRequisito>(find.byType(IndicadorRequisito))
          .every((regla) => regla.cumplido),
      isTrue,
    );
    expect(tester.widget<FilledButton>(crear).onPressed, isNotNull);
    await tester.ensureVisible(crear);
    await tester.tap(crear);
    await tester.pumpAndSettle();
    expect(servicio.registros, 1);
  });

  testWidgets('El acceso decodifica y muestra el PNG original', (tester) async {
    await abrirApp(tester, conSesion: false);
    final logo = find.byType(LogoTharpon);
    final imagen = find.descendant(of: logo, matching: find.byType(Image));
    final widget = tester.widget<Image>(imagen);
    expect(
      (widget.image as AssetImage).assetName,
      'assets/logos/logo_tarpon.png',
    );
    expect(widget.fit, BoxFit.contain);
    await tester.runAsync(
      () => precacheImage(widget.image, tester.element(imagen)),
    );
    await tester.pumpAndSettle();
    final render = tester.widget<RawImage>(
      find.descendant(of: imagen, matching: find.byType(RawImage)),
    );
    expect(render.image, isNotNull);
    expect(tester.getSize(imagen), const Size(200, 124));
    expect(widget.color, ColoresApp.textoPrincipal);
    expect(widget.colorBlendMode, BlendMode.srcIn);
    expect(find.text('THARPON / MX'), findsNothing);
  });

  testWidgets(
    'Acceso y registro se desplazan con teclado en ventana compacta',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await abrirApp(tester, conSesion: false);

      final enlace = find.text('¿No tienes cuenta? Regístrate');
      await tester.ensureVisible(enlace);
      await tester.tap(enlace);
      await tester.pumpAndSettle();
      final clave = find.byType(TextFormField).at(2);
      await tester.ensureVisible(clave);
      await tester.tap(clave);
      tester.view.viewInsets = const FakeViewPadding(bottom: 270);
      await tester.enterText(clave, 'Clave123!');
      await tester.pumpAndSettle();
      final confirmar = find.byType(TextFormField).at(3);
      await tester.ensureVisible(confirmar);
      await tester.pumpAndSettle();
      expect(confirmar.hitTestable(), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Solicita y completa la recuperación desde un enlace', (
    tester,
  ) async {
    final servicio = await abrirApp(tester, conSesion: false);
    final recuperar = find.text('¿Olvidaste tu contraseña?');
    await tester.ensureVisible(recuperar);
    await tester.tap(recuperar);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'cliente@example.com');
    await tester.tap(find.text('Enviar enlace de recuperación'));
    await tester.pumpAndSettle();
    expect(servicio.correoRecuperacion, 'cliente@example.com');
    expect(find.textContaining('recibirás un enlace'), findsOneWidget);

    servicio.abrirEnlaceRecuperacion();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('boton_menu')), findsNothing);
    expect(find.text('Crea una nueva contraseña'), findsOneWidget);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'NuevaClave123!');
    await tester.ensureVisible(campos.at(1));
    await tester.enterText(campos.at(1), 'NuevaClave123!');
    final guardar = find.text('Guardar contraseña');
    await tester.ensureVisible(guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();
    expect(servicio.contrasenaActualizada, 'NuevaClave123!');
    expect(servicio.sesion, isNull);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('El acceso administrativo rechaza a un cliente', (tester) async {
    final servicio = await abrirApp(tester, conSesion: false);
    final acceso = find.text('Acceso administrativo');
    await tester.ensureVisible(acceso);
    await tester.tap(acceso);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'cliente@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'clave de prueba');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(servicio.validacionAdmin, isTrue);
    expect(
      find.text('Tu cuenta no tiene acceso a esta sección.'),
      findsOneWidget,
    );
  });

  testWidgets('Una recuperación restaurada bloquea cualquier ruta privada', (
    tester,
  ) async {
    final servicio = _AutenticacionPrueba(conSesion: true, rol: RolPerfil.admin)
      ..recuperacionPendiente = true;
    addTearDown(servicio.eventos.close);
    await tester.pumpWidget(TarponMX(servicio: servicio));
    await tester.pumpAndSettle();
    expect(find.text('Crea una nueva contraseña'), findsOneWidget);

    servicio.renovarToken();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(servicio.consultasPerfil, 0);
    expect(
      find.byKey(const Key('boton_menu'), skipOffstage: false),
      findsNothing,
    );
  });

  testWidgets('Una renovación retira el acceso al administrador degradado', (
    tester,
  ) async {
    final servicio = await abrirApp(tester, rol: RolPerfil.admin);
    await tester.tap(find.byKey(const Key('boton_perfil')));
    await tester.pumpAndSettle();
    expect(find.text('Administrador'), findsOneWidget);
    servicio.rol = RolPerfil.cliente;
    servicio.renovarToken();
    await tester.pumpAndSettle();

    expect(servicio.consultasPerfil, 2);
    expect(
      find.text('Tu cuenta no tiene acceso a esta sección.'),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Perfil del Usuario', skipOffstage: false), findsNothing);
  });

  testWidgets('Al volver al primer plano se retira una cuenta desactivada', (
    tester,
  ) async {
    final servicio = await abrirApp(tester);
    final consulta = Completer<void>();
    servicio.esperaPerfil = consulta.future;
    servicio.activo = false;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    servicio.renovarToken();
    await tester.pump();
    expect(servicio.consultasPerfil, 2);
    consulta.complete();
    await tester.pumpAndSettle();

    expect(servicio.consultasPerfil, 2);
    expect(
      find.text('Tu cuenta no tiene acceso a esta sección.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('boton_menu'), skipOffstage: false),
      findsNothing,
    );
  });

  testWidgets('Cerrar sesión desde Perfil retira las rutas privadas', (
    tester,
  ) async {
    await abrirApp(tester, rol: RolPerfil.admin);
    await tester.tap(find.byKey(const Key('boton_perfil')));
    await tester.pumpAndSettle();
    expect(find.text('Administrador'), findsOneWidget);
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Perfil del Usuario', skipOffstage: false), findsNothing);
    expect(
      find.byKey(const Key('boton_menu'), skipOffstage: false),
      findsNothing,
    );
  });

  // ===================================================
  // PRUEBA 1: INICIO DE LA APLICACIÓN
  // ===================================================

  testWidgets('La aplicación inicia correctamente', (
    WidgetTester tester,
  ) async {
    // Construye nuestra aplicación.
    await abrirApp(tester);

    // Verifica que MaterialApp exista.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Comprueba que existe una barra superior
    // visible en la pantalla principal.
    expect(find.byType(AppBar), findsOneWidget);

    // Verifica los botones principales.
    expect(find.byKey(const Key('boton_zona')), findsOneWidget);

    expect(find.byKey(const Key('boton_perfil')), findsOneWidget);
  });

  // ===================================================
  // PRUEBA 2: MENÚ DESPLEGABLE
  // ===================================================

  testWidgets('El selector global se puede cancelar sin cambiar de pantalla', (
    tester,
  ) async {
    await abrirApp(tester);
    await tester.tap(find.byKey(const Key('boton_zona')));
    await tester.pumpAndSettle();
    expect(find.text('Tu zona de pesca'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Tu zona de pesca'), findsNothing);
    expect(find.text('¡Buena pesca!'), findsOneWidget);
  });

  // ===================================================
  // PRUEBA 3: NAVEGACIÓN DESDE INICIO
  // ===================================================

  testWidgets('El banner Clima abre su módulo', (WidgetTester tester) async {
    // Inicia la aplicación.
    await abrirApp(tester);

    // Localiza el banner de Clima.
    final bannerClima = find.byKey(const Key('banner_clima'));

    // Verifica que el banner existe.
    expect(bannerClima, findsOneWidget);

    // Presiona el banner.
    await tester.tap(bannerClima);

    // Actualiza la interfaz.
    await tester.pump();

    // Busca la pantalla de Clima.
    //
    // skipOffstage: false permite localizar
    // widgets que están dentro de IndexedStack.
    final pantallaClima = find.byType(PantallaCondiciones, skipOffstage: false);

    // Verificamos que la pantalla existe.
    expect(pantallaClima, findsOneWidget);

    // Comprobamos que IndexedStack ahora
    // muestra el módulo Clima.
    //
    // Según nuestro enum:
    // 0 = Inicio
    // 1 = Especies
    // 2 = Clima
    final contenedor = tester.widget<IndexedStack>(find.byType(IndexedStack));

    expect(contenedor.index, 2);
  });

  // ===================================================
  // PRUEBA 4: PERFIL
  // ===================================================

  testWidgets('El botón de Perfil abre su pantalla', (
    WidgetTester tester,
  ) async {
    await abrirApp(tester);

    // Presiona el botón superior derecho.
    await tester.tap(find.byKey(const Key('boton_perfil')));

    // Espera la transición de navegación.
    await tester.pumpAndSettle();

    // Comprueba que apareció la pantalla.
    expect(find.text('Perfil del Usuario'), findsOneWidget);
  });
}

class _AutenticacionPrueba implements ServicioAutenticacion {
  _AutenticacionPrueba({required bool conSesion, required this.rol})
    : sesion = conSesion ? _sesionPrueba : null;

  static final _sesionPrueba = Session(
    accessToken: 'token de prueba',
    tokenType: 'bearer',
    user: const User(
      id: 'perfil-prueba',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '',
    ),
  );
  RolPerfil rol;
  bool activo = true;
  int consultasPerfil = 0;
  Future<void>? esperaPerfil;
  @override
  bool recuperacionPendiente = false;
  final eventos = StreamController<AuthState>.broadcast();
  bool validacionAdmin = false;
  int registros = 0;
  String? correoRecuperacion;
  String? contrasenaActualizada;

  void abrirEnlaceRecuperacion() {
    recuperacionPendiente = true;
    sesion = _sesionPrueba;
    eventos.add(AuthState(AuthChangeEvent.passwordRecovery, sesion));
  }

  void renovarToken() {
    sesion = Session(
      accessToken: 'token renovado',
      tokenType: 'bearer',
      user: _sesionPrueba.user,
    );
    eventos.add(AuthState(AuthChangeEvent.tokenRefreshed, sesion));
  }

  @override
  Session? sesion;

  @override
  String? get redireccion => null;

  @override
  Stream<AuthState> get cambios => eventos.stream;

  @override
  Future<PerfilAutenticado> consultarPerfil(
    String id, {
    bool requiereAdmin = false,
  }) async {
    consultasPerfil++;
    if (esperaPerfil case final espera?) await espera;
    validacionAdmin = requiereAdmin;
    if (!activo || (requiereAdmin && rol != RolPerfil.admin)) {
      throw const AccesoRestringido();
    }
    return PerfilAutenticado(id: id, nombre: 'Perfil de prueba', rol: rol);
  }

  @override
  Future<void> iniciarSesion(String correo, String contrasena) async {
    sesion = _sesionPrueba;
    eventos.add(AuthState(AuthChangeEvent.signedIn, sesion));
  }

  @override
  Future<void> cerrarSesion() async {
    recuperacionPendiente = false;
    sesion = null;
    eventos.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<bool> registrar(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    registros++;
    return false;
  }

  @override
  Future<void> solicitarRecuperacion(String correo) async {
    correoRecuperacion = correo;
  }

  @override
  Future<void> cambiarContrasena(String contrasena) async {
    contrasenaActualizada = contrasena;
  }
}
