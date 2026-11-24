import 'package:flutter/material.dart';
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
}
