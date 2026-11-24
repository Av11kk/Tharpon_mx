import 'package:flutter/material.dart';

/// =====================================================
/// MODELO DE TARJETA DASHBOARD
/// =====================================================
///
/// Representa la información necesaria
/// para construir una tarjeta del Dashboard.
///
/// Ejemplo:
///
/// Clima
/// Mareas
/// Consejos
///
class TarjetaDashboardModelo {
  /// Icono de la tarjeta
  final IconData icono;

  /// Título principal
  final String titulo;

  /// Descripción
  final String descripcion;

  /// Constructor
  const TarjetaDashboardModelo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });
}
