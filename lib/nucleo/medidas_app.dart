import 'package:flutter/material.dart';

abstract final class MedidasApp {
  static const pequeno = 8.0;
  static const medio = 12.0;
  static const normal = 16.0;
  static const interiorTarjeta = 20.0;
  static const margenPantalla = 22.0;
  static const amplio = 24.0;
  static const separacionCampo = 14.0;
  static const radioSecundario = 8.0;
  static const radioCampoRegistro = 10.0;
  static const radioControl = 12.0;
  static const radioDialogo = 16.0;
  static const radioEstado = 14.0;
  static const radioTarjetaAcceso = 18.0;
  static const radioTarjeta = 20.0;
  static const altoControl = 48.0;
  static const altoAccionPrincipal = 50.0;
  static const iconoCampo = 20.0;
  static const icono = 24.0;
  static const anchoAcceso = 390.0;
  static const anchoEstado = 330.0;
  static const ilustracionEstado = Size(180, 96);
  static const elevacionTarjeta = 0.0;
}

abstract final class MovimientoApp {
  static const pulsacion = Duration(milliseconds: 120);
  static const elevacion = Duration(milliseconds: 180);
  static const dialogo = Duration(milliseconds: 220);
  static const pantalla = Duration(milliseconds: 250);
  static const menu = Duration(milliseconds: 280);
  static const confirmacion = Duration(milliseconds: 800);
  static const cargaIdentidad = Duration(milliseconds: 2800);
  static const salida = Curves.easeOutCubic;
  static const entrada = Curves.easeInCubic;
  static const recorrido = Offset(0, 0.025);

  static Duration duracion(BuildContext context, Duration normal) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : normal;
}
