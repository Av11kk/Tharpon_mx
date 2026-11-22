import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/estado_operacion.dart';
import '../navegacion/pantalla_navegacion.dart';
import 'pantalla_login.dart';

class ControlAcceso extends StatefulWidget {
  const ControlAcceso({super.key, required this.servicio, this.cliente});

  final ServicioAutenticacion servicio;
  final SupabaseClient? cliente;

  @override
  State<ControlAcceso> createState() => _ControlAccesoState();
}

class _ControlAccesoState extends State<ControlAcceso>
    with WidgetsBindingObserver {
  var _navegador = GlobalKey<NavigatorState>();
  late final StreamSubscription<AuthState> _suscripcion;
  String? _id;
  PerfilAutenticado? _perfil;
  bool _recuperando = false;
  bool _requiereAdmin = false;
  bool _validando = false;
  int _revision = 0;
  String? _tokenValidado;
  String? _aviso;
  Object? _errorSesion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sincronizarSesion(widget.servicio.sesion);
    unawaited(_validar(widget.servicio.sesion, forzar: false));
    _suscripcion = widget.servicio.cambios.listen(
      _actualizarSesion,
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _invalidarValidacion();
          _errorSesion = error;
        });
      },
    );
  }

  void _invalidarValidacion() {
    _revision++;
    _validando = false;
    _perfil = null;
    _tokenValidado = null;
    _navegador = GlobalKey<NavigatorState>();
  }

  void _sincronizarSesion(Session? sesion, {bool eventoRecuperacion = false}) {
    final id = sesion?.user.id;
    final recuperando =
        id != null &&
        (eventoRecuperacion ||
            (_id == id && _recuperando) ||
            widget.servicio.recuperacionPendiente);
    if (id != _id || recuperando != _recuperando) {
      _invalidarValidacion();
      _errorSesion = null;
    }
    _id = id;
    _recuperando = recuperando;
  }

  void _actualizarSesion(AuthState estado) {
    if (!mounted) return;
    final sesion = widget.servicio.sesion;
    if (estado.session?.accessToken != sesion?.accessToken) return;
    setState(() {
      _sincronizarSesion(
        sesion,
        eventoRecuperacion: estado.event == AuthChangeEvent.passwordRecovery,
      );
      if (estado.event == AuthChangeEvent.signedOut) {
        _requiereAdmin = false;
        _errorSesion = null;
      }
    });
    _validar(sesion, forzar: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reintentar();
  }

  void _reintentar() {
    final sesion = widget.servicio.sesion;
    setState(() {
      _sincronizarSesion(sesion);
      _errorSesion = null;
    });
    _validar(sesion, forzar: true);
  }

  Future<void> _validar(Session? sesion, {required bool forzar}) async {
    if (sesion == null ||
        _recuperando ||
        _validando ||
        (!forzar && _tokenValidado == sesion.accessToken)) {
      return;
    }
    final id = sesion.user.id;
    final revision = _revision;
    setState(() => _validando = true);
    // Registra el token antes de consultar para agrupar eventos del mismo token.
    _tokenValidado = sesion.accessToken;
    try {
      final perfil = await widget.servicio.consultarPerfil(
        id,
        requiereAdmin: _requiereAdmin || _perfil?.rol == RolPerfil.admin,
      );
      if (!mounted || revision != _revision) return;
      setState(() {
        if (_perfil != null && _perfil?.rol != perfil.rol) {
          _navegador = GlobalKey<NavigatorState>();
        }
        _perfil = perfil;
        _requiereAdmin = _requiereAdmin || perfil.rol == RolPerfil.admin;
        _errorSesion = null;
      });
    } catch (error) {
      if (!mounted || revision != _revision) return;
      setState(() {
        _perfil = null;
        _navegador = GlobalKey<NavigatorState>();
        _errorSesion = error;
      });
    } finally {
      if (mounted && revision == _revision) {
        setState(() => _validando = false);
        final actual = widget.servicio.sesion;
        if (_errorSesion != null &&
            _errorSesion is! AccesoRestringido &&
            actual?.user.id == id &&
            actual?.accessToken != sesion.accessToken) {
          unawaited(_validar(actual, forzar: false));
        } else {
          // Una consulta al mismo perfil cubre ambas señales simultáneas.
          _tokenValidado = actual?.accessToken;
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_suscripcion.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorSesion case final error?) {
      return PantallaEstadoAcceso(
        tipo: tipoErrorAcceso(error),
        mensaje: mensajeErrorAcceso(error),
        accion: error is AccesoRestringido ? null : _reintentar,
        cerrarSesion: _id == null ? null : widget.servicio.cerrarSesion,
      );
    }
    if (_id == null || _recuperando) {
      return PantallaLogin(
        key: ValueKey(_recuperando),
        servicio: widget.servicio,
        nuevaContrasena: _recuperando,
        aviso: _aviso,
        alCambiarAcceso: (admin) {
          _requiereAdmin = admin;
          _aviso = null;
        },
        alRestablecer: () {
          _aviso =
              'Contraseña actualizada. Inicia sesión con tu nueva contraseña.';
        },
      );
    }
    final perfil = _perfil;
    if (perfil == null) {
      return const PantallaEstadoAcceso(
        mensaje: 'Verificando tu perfil…',
        tipo: TipoEstadoOperacion.carga,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: _validando,
          child: NavigatorPopHandler<Object?>(
            enabled: !_validando,
            key: ValueKey((perfil.id, perfil.rol)),
            onPopWithResult: (resultado) =>
                _navegador.currentState?.pop(resultado),
            child: Navigator(
              key: _navegador,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => PantallaNavegacion(
                  perfil: perfil,
                  cliente: widget.cliente,
                  cerrarSesion: widget.servicio.cerrarSesion,
                ),
              ),
            ),
          ),
        ),
        if (_validando)
          const PantallaEstadoAcceso(
            mensaje: 'Verificando tu perfil…',
            tipo: TipoEstadoOperacion.carga,
          ),
      ],
    );
  }
}
