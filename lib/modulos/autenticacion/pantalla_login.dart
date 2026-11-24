import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/estado_operacion.dart';
import '../../compartido/widgets/logo_tarpon.dart';

import '../../compartido/widgets/controles_app.dart';
import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';
import '../../nucleo/tema_app.dart';

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
  static final _formatoCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  late final _camposRegistro = Listenable.merge([
    _nombre,
    _correo,
    _contrasena,
    _confirmacion,
  ]);

  bool get _claveNueva => _modo == _Modo.registro || _modo == _Modo.restablecer;
  bool _claveValida(String clave) =>
      _requisitos.every((regla) => regla.$2(clave));
  bool get _registroValido {
    final nombre = _nombre.text.trim();
    return nombre.isNotEmpty &&
        nombre.runes.length <= 120 &&
        _formatoCorreo.hasMatch(_correo.text.trim()) &&
        _claveValida(_contrasena.text) &&
        _contrasena.text == _confirmacion.text;
  }

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
    required Color relleno,
  }) => CampoApp(
    controlador: controller,
    etiqueta: etiqueta,
    pista: pista,
    validar: validar,
    autocompletar: autofill,
    habilitado: !_ocupado,
    oculto: clave && !_visible,
    alCambiarVisibilidad: clave
        ? () => setState(() => _visible = !_visible)
        : null,
    etiquetaInterna: etiquetaInterna,
    etiquetaFlotante: _modo == _Modo.recuperar,
    relleno: relleno,
    borde: relleno == ColoresApp.tarjeta
        ? Colors.transparent
        : (_modo == _Modo.registro ? ColoresApp.borde : ColoresApp.bordeAcceso),
    radio: _modo == _Modo.registro
        ? MedidasApp.radioCampoRegistro
        : MedidasApp.radioControl,
    icono: recurso == null
        ? null
        : Center(
            widthFactor: 1,
            heightFactor: 1,
            child: SvgPicture.asset(
              'assets/autenticacion/$recurso.svg',
              width: MedidasApp.iconoCampo,
              height: MedidasApp.iconoCampo,
            ),
          ),
  );

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
      _Modo.login => _admin ? null : 'Accede a tu cuenta',
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
        ? ColoresApp.superficie
        : (panel ? ColoresApp.campoAcceso : ColoresApp.tarjeta);
    final mensaje = _mensaje ?? widget.aviso;

    return _MarcoAcceso(
      key: ValueKey((_modo, _admin)),
      encabezadoAdmin: loginAdmin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!loginAdmin) ...[
            const SizedBox(height: MedidasApp.normal),
            if (panel) ...[
              Center(
                child: LogoTharpon(
                  ancho: loginCliente ? 200 : 164,
                  alto: loginCliente ? 124 : 102,
                  variante: VarianteLogo.fondoOscuro,
                ),
              ),
              Text(
                'Tu próxima aventura comienza aquí',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else
              const Align(
                alignment: Alignment.centerLeft,
                child: LogoTharpon(
                  ancho: 140,
                  alto: 87,
                  variante: VarianteLogo.fondoOscuro,
                ),
              ),
          ],
          const SizedBox(height: MedidasApp.amplio),
          EncabezadoApp(
            titulo: titulo,
            descripcion: descripcion,
            destacado: registro,
          ),
          const SizedBox(height: MedidasApp.interiorTarjeta),
          _ContenedorFormulario(
            panel: panel,
            registro: registro,
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
                      const SizedBox(height: MedidasApp.medio),
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
                        validar: (s) => _formatoCorreo.hasMatch(s?.trim() ?? '')
                            ? null
                            : 'Escribe un correo válido.',
                      ),
                    if (_modo != _Modo.recuperar) ...[
                      if (_modo != _Modo.restablecer)
                        const SizedBox(height: MedidasApp.medio),
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
                      const SizedBox(height: MedidasApp.pequeno),
                      ValueListenableBuilder(
                        valueListenable: _contrasena,
                        builder: (context, valor, _) => valor.text.isEmpty
                            ? Text(
                                'Usa al menos 8 caracteres.',
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                            : Card(
                                color: ColoresApp.superficie,
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      MedidasApp.radioCampoRegistro,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    MedidasApp.medio,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Requisitos de contraseña',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      for (final regla in _requisitos)
                                        IndicadorRequisito(
                                          texto: regla.$1,
                                          cumplido: regla.$2(valor.text),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: MedidasApp.medio),
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
                      const SizedBox(height: MedidasApp.pequeno),
                      ListenableBuilder(
                        listenable: Listenable.merge([
                          _contrasena,
                          _confirmacion,
                        ]),
                        builder: (context, _) => IndicadorRequisito(
                          texto: 'Las contraseñas coinciden',
                          cumplido:
                              _confirmacion.text.isNotEmpty &&
                              _confirmacion.text == _contrasena.text,
                          error:
                              _confirmacion.text.isNotEmpty &&
                              _confirmacion.text != _contrasena.text,
                        ),
                      ),
                    ],
                    const SizedBox(height: MedidasApp.normal),
                    if (registro)
                      ListenableBuilder(
                        listenable: _camposRegistro,
                        builder: (context, _) => BotonPrincipal(
                          texto: accion,
                          icono: Icons.arrow_forward,
                          alPulsar: _ocupado || !_registroValido
                              ? null
                              : _enviar,
                        ),
                      )
                    else
                      BotonPrincipal(
                        texto: accion,
                        alineacion: panel
                            ? Alignment.center
                            : AlignmentDirectional.centerStart,
                        alPulsar: _ocupado ? null : _enviar,
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
                              padding: EdgeInsets.only(
                                top: MedidasApp.separacionCampo,
                              ),
                              child: EstadoOperacion(
                                tipo: TipoEstadoOperacion.carga,
                                mensaje: 'Procesando solicitud…',
                              ),
                            )
                          : mensaje == null
                          ? const SizedBox.shrink()
                          : Padding(
                              key: ValueKey((_tipo, mensaje)),
                              padding: const EdgeInsets.only(
                                top: MedidasApp.separacionCampo,
                              ),
                              child: NotificacionApp(
                                tipo: _tipo,
                                mensaje: mensaje,
                                titulo:
                                    _tipo == TipoEstadoOperacion.exito &&
                                        _mensaje != null
                                    ? 'Revisa tu correo'
                                    : null,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loginAdmin) ...[
            const SizedBox(height: MedidasApp.medio),
            Text(
              'Solo personal autorizado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: MedidasApp.amplio),
          ],
          if (_modo == _Modo.login) ...[
            const SizedBox(height: MedidasApp.pequeno),
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
              padding: const EdgeInsets.only(top: MedidasApp.normal),
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

  Widget _botonSecundario(String texto, VoidCallback accion) => BotonSecundario(
    texto: texto,
    enlace: _modo == _Modo.registro,
    alPulsar: _ocupado ? null : accion,
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
        padding: const EdgeInsets.only(top: MedidasApp.amplio),
        child: PanelEstadoApp(
          tipo: _ocupado
              ? TipoEstadoOperacion.carga
              : (error == null ? widget.tipo : tipoErrorAcceso(error)),
          mensaje: _ocupado
              ? 'Cerrando sesión…'
              : (error == null ? widget.mensaje : mensajeErrorAcceso(error)),
          acciones: [
            if (widget.accion != null)
              BotonSecundario(
                texto: 'Reintentar',
                alPulsar: _ocupado ? null : widget.accion,
              ),
            if (widget.cerrarSesion != null)
              BotonSecundario(
                texto: 'Cerrar sesión',
                enlace: true,
                alPulsar: _ocupado ? null : _salir,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContenedorFormulario extends StatelessWidget {
  const _ContenedorFormulario({
    required this.panel,
    required this.registro,
    required this.child,
  });

  final bool panel, registro;
  final Widget child;

  @override
  Widget build(BuildContext context) => panel
      ? TarjetaApp(
          radio: registro
              ? MedidasApp.radioTarjeta
              : MedidasApp.radioTarjetaAcceso,
          borde: registro
              ? ColoresApp.seleccionado
              : ColoresApp.bordeTarjetaAcceso,
          child: child,
        )
      : child;
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
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: TemaApp.barraSistema,
    child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (encabezadoAdmin)
                const ColoredBox(
                  color: ColoresApp.tarjeta,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MedidasApp.margenPantalla,
                      vertical: MedidasApp.pequeno,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LogoTharpon(
                          ancho: 120,
                          alto: 74,
                          variante: VarianteLogo.fondoOscuro,
                          alineacion: Alignment.centerLeft,
                        ),
                        Text('ADMINISTRACIÓN'),
                      ],
                    ),
                  ),
                ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: MedidasApp.anchoAcceso,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MedidasApp.margenPantalla,
                      0,
                      MedidasApp.margenPantalla,
                      MedidasApp.margenPantalla,
                    ),
                    child: AparicionApp(child: child),
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
