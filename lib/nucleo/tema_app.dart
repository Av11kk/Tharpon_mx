import 'package:flutter/material.dart';
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
}
