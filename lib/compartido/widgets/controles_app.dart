import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';
import '../../nucleo/medidas_app.dart';

class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.icono,
    this.alineacion = Alignment.center,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final IconData? icono;
  final AlignmentGeometry alineacion;

  @override
  Widget build(BuildContext context) {
    final estilo = FilledButton.styleFrom(alignment: alineacion);
    if (icono case final icono?) {
      return FilledButton.icon(
        onPressed: alPulsar,
        style: estilo,
        icon: Icon(icono),
        iconAlignment: IconAlignment.end,
        label: Text(texto),
      );
    }
    return FilledButton(onPressed: alPulsar, style: estilo, child: Text(texto));
  }
}

class BotonSecundario extends StatelessWidget {
  const BotonSecundario({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.enlace = false,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final bool enlace;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: alPulsar,
    style: enlace
        ? null
        : TextButton.styleFrom(
            alignment: AlignmentDirectional.centerStart,
            backgroundColor: ColoresApp.accionSecundaria,
          ),
    child: Text(texto),
  );
}

class CampoApp extends StatelessWidget {
  const CampoApp({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.pista,
    required this.validar,
    required this.autocompletar,
    required this.habilitado,
    this.icono,
    this.oculto = false,
    this.alCambiarVisibilidad,
    this.etiquetaInterna = false,
    this.etiquetaFlotante = false,
    this.relleno = ColoresApp.superficie,
    this.borde = ColoresApp.borde,
    this.radio = MedidasApp.radioControl,
  });

  final TextEditingController controlador;
  final String etiqueta, pista, autocompletar;
  final FormFieldValidator<String> validar;
  final bool habilitado, oculto, etiquetaInterna, etiquetaFlotante;
  final Widget? icono;
  final VoidCallback? alCambiarVisibilidad;
  final Color relleno, borde;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final clave = alCambiarVisibilidad != null;
    final estilos = Theme.of(context).textTheme;
    final forma = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radio),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!etiquetaInterna) ...[
          ExcludeSemantics(child: Text(etiqueta, style: estilos.titleSmall)),
          const SizedBox(height: MedidasApp.pequeno),
        ],
        Semantics(
          label: etiquetaInterna ? null : etiqueta,
          child: TextFormField(
            controller: controlador,
            enabled: habilitado,
            obscureText: oculto,
            autofillHints: [autocompletar],
            keyboardType: autocompletar == AutofillHints.email
                ? TextInputType.emailAddress
                : null,
            autocorrect: !clave && autocompletar == AutofillHints.name,
            enableSuggestions: !clave,
            validator: validar,
            style: estilos.bodyMedium,
            decoration: InputDecoration(
              labelText: etiquetaInterna ? etiqueta : null,
              floatingLabelBehavior: etiquetaFlotante
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.auto,
              hintText: pista,
              fillColor: relleno,
              enabledBorder: forma.copyWith(
                borderSide: borde == Colors.transparent
                    ? BorderSide.none
                    : BorderSide(color: borde),
              ),
              focusedBorder: forma.copyWith(
                borderSide: const BorderSide(color: ColoresApp.textoPrincipal),
              ),
              errorBorder: forma.copyWith(
                borderSide: const BorderSide(color: ColoresApp.error),
              ),
              focusedErrorBorder: forma.copyWith(
                borderSide: const BorderSide(color: ColoresApp.error, width: 2),
              ),
              border: forma,
              prefixIcon: icono,
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
              suffixIcon: clave
                  ? IconButton(
                      tooltip: oculto
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: habilitado ? alCambiarVisibilidad : null,
                      icon: Icon(
                        oculto
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class TarjetaApp extends StatelessWidget {
  const TarjetaApp({
    super.key,
    required this.child,
    this.borde,
    this.radio = MedidasApp.radioTarjeta,
  });

  final Widget child;
  final Color? borde;
  final double radio;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
      side: borde == null ? BorderSide.none : BorderSide(color: borde!),
    ),
    child: Padding(
      padding: const EdgeInsets.all(MedidasApp.interiorTarjeta),
      child: child,
    ),
  );
}

class EncabezadoApp extends StatelessWidget {
  const EncabezadoApp({
    super.key,
    required this.titulo,
    this.descripcion,
    this.destacado = false,
  });

  final String titulo;
  final String? descripcion;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          style: destacado ? estilos.headlineMedium : estilos.headlineSmall,
        ),
        if (descripcion case final descripcion?) ...[
          const SizedBox(height: MedidasApp.pequeno),
          Text(
            descripcion,
            style: estilos.bodyMedium?.copyWith(
              color: ColoresApp.textoSecundario,
            ),
          ),
        ],
      ],
    );
  }
}

Future<bool?> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
  bool navegadorRaiz = true,
}) => showDialog<bool>(
  context: context,
  useRootNavigator: navegadorRaiz,
  animationStyle: AnimationStyle(
    duration: MovimientoApp.duracion(context, MovimientoApp.dialogo),
    curve: MovimientoApp.salida,
    reverseCurve: MovimientoApp.entrada,
  ),
  builder: (context) => AlertDialog(
    title: Text(titulo),
    content: Text(mensaje),
    actions: [
      BotonSecundario(
        texto: 'Cancelar',
        enlace: true,
        alPulsar: () => Navigator.pop(context, false),
      ),
      BotonPrincipal(
        texto: accion,
        alPulsar: () => Navigator.pop(context, true),
      ),
    ],
  ),
);
