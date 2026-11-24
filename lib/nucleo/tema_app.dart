import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';

import 'colores_app.dart';
import 'medidas_app.dart';

abstract final class TemaApp {
  static const barraSistema = SystemUiOverlayStyle.light;
  static const familia = 'Inter';

  static const tipografia = TextTheme(
    headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(
      fontFamily: familia,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 13, color: ColoresApp.textoSecundario),
    labelMedium: TextStyle(fontSize: 12, color: ColoresApp.etiqueta),
  );

  static final oscuro = ThemeData(
    fontFamily: familia,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: ColoresApp.primario,
      onPrimary: ColoresApp.textoPrincipal,
      secondary: ColoresApp.etiqueta,
      onSecondary: ColoresApp.tarjeta,
      surface: ColoresApp.fondo,
      onSurface: ColoresApp.textoPrincipal,
      onSurfaceVariant: ColoresApp.textoSecundario,
      surfaceContainer: ColoresApp.superficie,
      surfaceContainerHigh: ColoresApp.seleccionado,
      outline: ColoresApp.bordeAcceso,
      outlineVariant: ColoresApp.borde,
      error: ColoresApp.error,
      onError: ColoresApp.tarjeta,
    ),
    scaffoldBackgroundColor: ColoresApp.fondo,
    textTheme: tipografia,
    iconTheme: const IconThemeData(
      color: ColoresApp.etiqueta,
      size: MedidasApp.icono,
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: ColoresApp.tarjeta,
      foregroundColor: ColoresApp.textoPrincipal,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: barraSistema,
    ),
    cardTheme: const CardThemeData(
      color: ColoresApp.tarjeta,
      elevation: MedidasApp.elevacionTarjeta,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(MedidasApp.radioTarjeta),
        ),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: ColoresApp.panelNavegacion,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(MedidasApp.radioDialogo),
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: ColoresApp.tarjeta,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(MedidasApp.radioDialogo),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ColoresApp.panelNavegacion,
      contentTextStyle: TextStyle(color: ColoresApp.textoPrincipal),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: ColoresApp.superficie,
      hintStyle: tipografia.bodySmall,
      labelStyle: tipografia.bodySmall,
      errorStyle: const TextStyle(color: ColoresApp.error),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MedidasApp.medio,
        vertical: MedidasApp.normal,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(MedidasApp.radioControl),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        disabledBackgroundColor: ColoresApp.borde,
        disabledForegroundColor: ColoresApp.textoSecundario,
        minimumSize: const Size(0, MedidasApp.altoAccionPrincipal),
        animationDuration: MovimientoApp.pulsacion,
        textStyle: tipografia.titleSmall,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MedidasApp.radioControl),
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColoresApp.textoPrincipal,
        minimumSize: const Size(0, MedidasApp.altoControl),
        animationDuration: MovimientoApp.pulsacion,
        textStyle: tipografia.titleSmall,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MedidasApp.radioSecundario),
          ),
        ),
      ),
    ),
  );
=======
import 'package:forui/forui.dart';

/// Paletas para comparar las tres direcciones visuales de Tarpon.
enum EstiloTarpon {
  oceano(
    nombre: 'Océano nocturno',
    numero: '01',
    fondo: Color(0xFF081B29),
    superficie: Color(0xFF102D3D),
    texto: Color(0xFFF2F7F5),
    secundario: Color(0xFFA9C1C4),
    acento: Color(0xFF36C6BE),
    contraste: Color(0xFF062B30),
    borde: Color(0xFF274757),
    destacado: Color(0xFFE2CBA5),
    gradiente: [Color(0xFF125668), Color(0xFF103746), Color(0xFF102D3D)],
    oscuro: true,
  ),
  costa(
    nombre: 'Costa clara',
    numero: '02',
    fondo: Color(0xFFFAFAF5),
    superficie: Color(0xFFFFFFFF),
    texto: Color(0xFF123C50),
    secundario: Color(0xFF62777C),
    acento: Color(0xFF168C96),
    contraste: Color(0xFFFFFFFF),
    borde: Color(0xFFE4ECE8),
    destacado: Color(0xFFB07A42),
    gradiente: [Color(0xFF147B87), Color(0xFF176778), Color(0xFF124B60)],
    oscuro: false,
  ),
  tropico(
    nombre: 'Trópico en movimiento',
    numero: '03',
    fondo: Color(0xFFFFF8EA),
    superficie: Color(0xFFFFFFFF),
    texto: Color(0xFF153D4A),
    secundario: Color(0xFF617E7C),
    acento: Color(0xFF007E79),
    contraste: Color(0xFFFFFFFF),
    borde: Color(0xFFF0E5D3),
    destacado: Color(0xFFC45136),
    gradiente: [Color(0xFF008C8A), Color(0xFF087BA3), Color(0xFF155B80)],
    oscuro: false,
  );

  const EstiloTarpon({
    required this.nombre,
    required this.numero,
    required this.fondo,
    required this.superficie,
    required this.texto,
    required this.secundario,
    required this.acento,
    required this.contraste,
    required this.borde,
    required this.destacado,
    required this.gradiente,
    required this.oscuro,
  });

  final String nombre;
  final String numero;
  final Color fondo;
  final Color superficie;
  final Color texto;
  final Color secundario;
  final Color acento;
  final Color contraste;
  final Color borde;
  final Color destacado;
  final List<Color> gradiente;
  final bool oscuro;

  EstiloTarpon get siguiente => values[(index + 1) % values.length];

  FThemeData get temaForui {
    final base = oscuro
        ? FTheme.neutral.dark.touch
        : FTheme.neutral.light.touch;
    return FThemeData(
      touch: true,
      colors: base.colors.copyWith(
        background: fondo,
        foreground: texto,
        primary: acento,
        primaryForeground: contraste,
        card: superficie,
        border: borde,
        mutedForeground: secundario,
      ),
    );
  }
>>>>>>> c268b89c42e3fce6a2329e3909f014ebd7223ec9
}
