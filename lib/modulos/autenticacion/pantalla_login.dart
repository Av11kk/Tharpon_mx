import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/estado_operacion.dart';
import '../../compartido/widgets/logo_tarpon.dart';

const _fondo = Color(0xff2a2a2a);
const _panel = Color(0xff191919);
const _texto = Color(0xfff5f5f5);
const _secundario = Color(0xffbebebe);
const _accion = Color(0xffe0e0e0);

TipoEstadoOperacion tipoErrorAcceso(Object error) =>
    error is AuthRetryableFetchException || error is ClientException
    ? TipoEstadoOperacion.desconexion
    : TipoEstadoOperacion.error;

String mensajeErrorAcceso(Object error) {
  if (error is AccesoRestringido) {
    return 'Tu cuenta no tiene acceso a esta sección.';
  }
  if (tipoErrorAcceso(error) == TipoEstadoOperacion.desconexion) {
    return 'No pudimos conectar con el servidor. Intenta de nuevo.';
  }
  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => 'El correo o la contraseña son incorrectos.',
      'email_not_confirmed' => 'Confirma tu correo antes de iniciar sesión.',
      'weak_password' => 'La contraseña no cumple los requisitos.',
      'over_email_send_rate_limit' || 'over_request_rate_limit' =>
        'Espera un momento antes de volver a intentarlo.',
      'otp_expired' ||
      'flow_state_expired' => 'El enlace caducó. Solicita uno nuevo.',
      _ => 'No se pudo completar la solicitud. Intenta de nuevo.',
    };
  }
  return 'No se pudo completar la operación. Intenta de nuevo.';
}

enum _Modo { login, registro, recuperar, restablecer }

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    super.key,
    required this.servicio,
    required this.alCambiarAcceso,
    required this.alRestablecer,
    this.nuevaContrasena = false,
    this.aviso,
  });

  final ServicioAutenticacion servicio;
  final ValueChanged<bool> alCambiarAcceso;
  final VoidCallback alRestablecer;
  final bool nuevaContrasena;
  final String? aviso;

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();

  late _Modo _modo = widget.nuevaContrasena ? _Modo.restablecer : _Modo.login;
  bool _admin = false;
  bool _ocupado = false;
  bool _visible = false;
  String? _mensaje;
  TipoEstadoOperacion _tipo = TipoEstadoOperacion.exito;

  static final _requisitos = <(String, bool Function(String))>[
    ('Al menos 8 caracteres', (s) => s.runes.length >= 8),
    ('Una letra mayúscula', RegExp(r'[A-ZÁÉÍÓÚÜÑ]').hasMatch),
    ('Una letra minúscula', RegExp(r'[a-záéíóúüñ]').hasMatch),
    ('Al menos un número', RegExp(r'[0-9]').hasMatch),
    ('Un carácter especial', RegExp(r'[^\w\sÁÉÍÓÚÜÑáéíóúüñ]').hasMatch),
  ];

  bool get _claveNueva => _modo == _Modo.registro || _modo == _Modo.restablecer;
  bool _claveValida(String clave) =>
      _requisitos.every((regla) => regla.$2(clave));

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  void _cambiar(_Modo modo, {bool? admin, String? mensaje}) {
    FocusScope.of(context).unfocus();
    _contrasena.clear();
    _confirmacion.clear();
    if (admin != null) {
      widget.alCambiarAcceso(admin);
      _admin = admin;
    }
    setState(() {
      _formulario = GlobalKey<FormState>();
      _modo = modo;
      _visible = false;
      _tipo = TipoEstadoOperacion.exito;
      _mensaje = mensaje;
    });
  }

  Future<void> _enviar() async {
    if (_ocupado || !_formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _ocupado = true;
      _mensaje = null;
    });
    final correo = _correo.text.trim();
    final clave = _contrasena.text;
    try {
      switch (_modo) {
        case _Modo.login:
          await widget.servicio.iniciarSesion(correo, clave);
        case _Modo.registro:
          final tieneSesion = await widget.servicio.registrar(
            _nombre.text.trim(),
            correo,
            clave,
          );
          if (mounted && !tieneSesion) {
            _cambiar(
              _Modo.login,
              mensaje: 'Si el registro está disponible, recibirás un correo para confirmar tu cuenta.',
            );
          }
        case _Modo.recuperar:
          await widget.servicio.solicitarRecuperacion(correo);
          if (mounted) {
            setState(() {
              _tipo = TipoEstadoOperacion.exito;
              _mensaje = 'Si el correo está asociado a una cuenta, recibirás un enlace de recuperación.';
            });
          }
        case _Modo.restablecer:
          await widget.servicio.cambiarContrasena(clave);
          if (mounted) widget.alRestablecer();
          await widget.servicio.cerrarSesion();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _tipo = tipoErrorAcceso(error);
          _mensaje = mensajeErrorAcceso(error);
        });
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required String pista,
    required String? Function(String?) validar,
    required String autofill,
    String? recurso,
    bool clave = false,
    bool etiquetaInterna = false,
    Color relleno = const Color(0xff202020),
  }) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: _modo == _Modo.registro
            ? const Color(0xff454545)
            : const Color(0xff737373),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!etiquetaInterna) ...[
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
        ],
        TextFormField(
          controller: controller,
          enabled: !_ocupado,
          obscureText: clave && !_visible,
          autofillHints: [autofill],
          keyboardType: autofill == AutofillHints.email
              ? TextInputType.emailAddress
              : null,
          autocorrect: !clave && autofill == AutofillHints.name,
          enableSuggestions: !clave,
          style: const TextStyle(color: _texto, fontSize: 14),
          validator: validar,
          decoration: InputDecoration(
            labelText: etiquetaInterna ? etiqueta : null,
            floatingLabelBehavior: _modo == _Modo.recuperar
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.auto,
            hintText: pista,
            labelStyle: const TextStyle(color: _secundario),
            hintStyle: const TextStyle(color: _secundario, fontSize: 13),
            errorStyle: const TextStyle(color: _texto),
            filled: true,
            fillColor: relleno,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            enabledBorder: relleno == _panel
                ? borde.copyWith(borderSide: BorderSide.none)
                : borde,
            focusedBorder: borde.copyWith(
              borderSide: const BorderSide(color: _texto),
            ),
            border: borde,
            prefixIcon: recurso == null
                ? null
                : Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: SvgPicture.asset(
                      'assets/autenticacion/$recurso.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: clave
                ? IconButton(
                    tooltip: _visible
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    onPressed: _ocupado
                        ? null
                        : () => setState(() => _visible = !_visible),
                    icon: Icon(
                      _visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final registro = _modo == _Modo.registro;
    final loginCliente = _modo == _Modo.login && !_admin;
    final loginAdmin = _modo == _Modo.login && _admin;
    final panel = registro || loginCliente;
    final titulo = switch (_modo) {
      _Modo.login => _admin ? 'Acceso administrativo' : 'Bienvenido de nuevo',
      _Modo.registro => 'Crea tu cuenta',
      _Modo.recuperar => 'Recuperar contraseña',
      _Modo.restablecer => 'Crea una nueva contraseña',
    };
    final descripcion = switch (_modo) {
      _Modo.login => _admin ? null : 'Accede a tu cuenta Tharpon MX',
      _Modo.registro => 'Únete a la comunidad de pesca deportiva.',
      _Modo.recuperar => 'Ingresa el correo asociado a tu cuenta.',
      _Modo.restablecer =>
        'Elige una contraseña para volver a acceder a tu cuenta.',
    };
    final accion = switch (_modo) {
      _Modo.login => 'Iniciar sesión',
      _Modo.registro => 'Crear cuenta',
      _Modo.recuperar => 'Enviar enlace de recuperación',
      _Modo.restablecer => 'Guardar contraseña',
    };
    final relleno = registro
        ? const Color(0xff262626)
        : (panel ? const Color(0xff202020) : _panel);
    final mensaje = _mensaje ?? widget.aviso;

    return _MarcoAcceso(
      key: ValueKey((_modo, _admin)),
      encabezadoAdmin: loginAdmin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!loginAdmin) ...[
            const SizedBox(height: 18),
            if (panel) ...[
              Center(
                child: LogoTharpon(ancho: 148, alto: loginCliente ? 132 : 62),
              ),
              const SizedBox(height: 8),
              const Text(
                'THARPON / MX',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu próxima aventura comienza aquí',
                textAlign: TextAlign.center,
                style: TextStyle(color: _secundario, fontSize: 13),
              ),
              SizedBox(height: loginCliente ? 112 : 30),
            ] else ...[
              const Text(
                'THARPON / MX',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 62),
            ],
          ] else
            const SizedBox(height: 136),
          Text(
            titulo,
            style: TextStyle(
              fontSize: registro ? 30 : 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (descripcion != null) ...[
            const SizedBox(height: 8),
            Text(descripcion, style: const TextStyle(color: _secundario)),
          ],
          SizedBox(height: panel ? 20 : 30),
          Container(
            padding: panel ? const EdgeInsets.all(20) : EdgeInsets.zero,
            decoration: panel
                ? BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: registro
                          ? const Color(0xff3a3a3a)
                          : const Color(0xffa0a0a0),
                    ),
                  )
                : null,
            child: AutofillGroup(
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (registro) ...[
                      _campo(
                        controller: _nombre,
                        etiqueta: 'Nombre completo',
                        pista: 'Escribe tu nombre',
                        autofill: AutofillHints.name,
                        recurso: 'nombre',
                        relleno: relleno,
                        validar: (s) {
                          final nombre = s?.trim() ?? '';
                          if (nombre.isEmpty) return 'Escribe tu nombre.';
                          return nombre.runes.length > 120
                              ? 'Usa hasta 120 caracteres.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_modo != _Modo.restablecer)
                      _campo(
                        controller: _correo,
                        etiqueta: 'Correo electrónico',
                        pista: 'correo@ejemplo.com',
                        autofill: AutofillHints.email,
                        recurso: registro ? 'correo' : null,
                        relleno: relleno,
                        etiquetaInterna: !panel,
                        validar: (s) =>
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(s?.trim() ?? '')
                            ? null
                            : 'Escribe un correo válido.',
                      ),
                    if (_modo != _Modo.recuperar) ...[
                      if (_modo != _Modo.restablecer)
                        const SizedBox(height: 12),
                      _campo(
                        controller: _contrasena,
                        etiqueta: 'Contraseña',
                        pista: _claveNueva ? 'Crea una contraseña' : '••••••••',
                        autofill: _claveNueva
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                        recurso: registro ? 'contrasena' : null,
                        relleno: relleno,
                        etiquetaInterna: loginAdmin,
                        clave: true,
                        validar: (s) {
                          if (s == null || s.isEmpty) {
                            return 'Escribe tu contraseña.';
                          }
                          return _claveNueva && !_claveValida(s)
                              ? 'Cumple todos los requisitos.'
                              : null;
                        },
                      ),
                    ],
                    if (_claveNueva) ...[
                      const SizedBox(height: 10),
                      ValueListenableBuilder(
                        valueListenable: _contrasena,
                        builder: (context, valor, _) => valor.text.isEmpty
                            ? const Text(
                                'Usa al menos 8 caracteres.',
                                style: TextStyle(
                                  color: _secundario,
                                  fontSize: 12,
                                ),
                              )
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xff262626),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Requisitos de contraseña'),
                                      for (final regla in _requisitos)
                                        Text(
                                          '${regla.$2(valor.text) ? '✓' : '○'}  ${regla.$1}',
                                          style: const TextStyle(
                                            color: _secundario,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      _campo(
                        controller: _confirmacion,
                        etiqueta: 'Confirmar contraseña',
                        pista: 'Repite tu contraseña',
                        autofill: AutofillHints.newPassword,
                        recurso: registro ? 'contrasena' : null,
                        relleno: relleno,
                        clave: true,
                        validar: (s) =>
                            s == _contrasena.text && (s?.isNotEmpty ?? false)
                            ? null
                            : 'Las contraseñas deben coincidir.',
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        alignment: panel
                            ? Alignment.center
                            : Alignment.centerLeft,
                        minimumSize: Size.fromHeight(panel ? 50 : 44),
                      ),
                      onPressed: _ocupado ? null : _enviar,
                      child: Text(accion),
                    ),
                    if (loginCliente)
                      TextButton(
                        onPressed: _ocupado
                            ? null
                            : () => _cambiar(_Modo.registro),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    TransicionEstado(
                      child: _ocupado
                          ? const Padding(
                              key: ValueKey(TipoEstadoOperacion.carga),
                              padding: EdgeInsets.only(top: 14),
                              child: EstadoOperacion(
                                tipo: TipoEstadoOperacion.carga,
                                mensaje: 'Procesando solicitud…',
                              ),
                            )
                          : mensaje == null
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey((_tipo, mensaje)),
                              padding: const EdgeInsets.only(top: 14),
                              child: EstadoOperacion(
                                tipo: _tipo,
                                mensaje: mensaje,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loginAdmin) ...[
            const SizedBox(height: 12),
            const Text(
              'Solo personal autorizado',
              style: TextStyle(color: _secundario),
            ),
            const SizedBox(height: 110),
          ],
          if (_modo == _Modo.login) ...[
            const SizedBox(height: 10),
            _botonSecundario(
              '¿Olvidaste tu contraseña?',
              () => _cambiar(_Modo.recuperar),
            ),
            TextButton(
              onPressed: _ocupado
                  ? null
                  : () => _cambiar(_Modo.login, admin: !_admin),
              child: Text(
                _admin ? 'Acceso de clientes' : 'Acceso administrativo',
              ),
            ),
          ] else if (_modo != _Modo.restablecer)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _botonSecundario(
                registro
                    ? '¿Ya tienes cuenta? Inicia sesión'
                    : 'Regresar al inicio de sesión',
                () => _cambiar(_Modo.login),
              ),
            )
          else
            TextButton(
              onPressed: _ocupado ? null : _cancelarRestablecimiento,
              child: const Text('Cancelar y cerrar sesión'),
            ),
        ],
      ),
    );
  }

  Widget _botonSecundario(String texto, VoidCallback accion) => TextButton(
    style: TextButton.styleFrom(
      minimumSize: const Size.fromHeight(44),
      alignment: _modo == _Modo.registro
          ? Alignment.center
          : Alignment.centerLeft,
      backgroundColor: _modo == _Modo.registro ? null : const Color(0xff303030),
    ),
    onPressed: _ocupado ? null : accion,
    child: Text(texto),
  );

  Future<void> _cancelarRestablecimiento() async {
    setState(() => _ocupado = true);
    try {
      await widget.servicio.cerrarSesion();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tipo = tipoErrorAcceso(error);
        _mensaje = mensajeErrorAcceso(error);
      });
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }
}

class PantallaEstadoAcceso extends StatefulWidget {
  const PantallaEstadoAcceso({
    super.key,
    required this.mensaje,
    this.tipo = TipoEstadoOperacion.error,
    this.accion,
    this.cerrarSesion,
  });

  final String mensaje;
  final TipoEstadoOperacion tipo;
  final VoidCallback? accion;
  final Future<void> Function()? cerrarSesion;

  @override
  State<PantallaEstadoAcceso> createState() => _PantallaEstadoAccesoState();
}

class _PantallaEstadoAccesoState extends State<PantallaEstadoAcceso> {
  bool _ocupado = false;
  Object? _error;

  Future<void> _salir() async {
    setState(() => _ocupado = true);
    try {
      await widget.cerrarSesion!();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return _MarcoAcceso(
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: LogoTharpon(ancho: 148, alto: 112)),
            const SizedBox(height: 24),
            EstadoOperacion(
              tipo: _ocupado
                  ? TipoEstadoOperacion.carga
                  : (error == null ? widget.tipo : tipoErrorAcceso(error)),
              mensaje: _ocupado
                  ? 'Cerrando sesión…'
                  : (error == null
                        ? widget.mensaje
                        : mensajeErrorAcceso(error)),
            ),
            if (widget.accion != null)
              TextButton(
                onPressed: _ocupado ? null : widget.accion,
                child: const Text('Reintentar'),
              ),
            if (widget.cerrarSesion != null)
              TextButton(
                onPressed: _ocupado ? null : _salir,
                child: const Text('Cerrar sesión'),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarcoAcceso extends StatelessWidget {
  const _MarcoAcceso({
    super.key,
    required this.child,
    this.encabezadoAdmin = false,
  });

  final Widget child;
  final bool encabezadoAdmin;

  @override
  Widget build(BuildContext context) {
    final tema = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _accion,
        onPrimary: _panel,
        surface: _fondo,
        onSurface: _texto,
        error: _texto,
        onError: _panel,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _texto,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
    return Theme(
      data: tema,
      child: Scaffold(
        backgroundColor: _fondo,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (encabezadoAdmin)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THARPON / MX',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ADMINISTRACIÓN',
                            style: TextStyle(fontSize: 10, color: _secundario),
                          ),
                        ],
                      ),
                    ),
                  ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
