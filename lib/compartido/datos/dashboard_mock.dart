import 'package:flutter/material.dart';

import '../modelos/tarjeta_dashboard_modelo.dart';

/// =====================================================
/// DATOS SIMULADOS
/// =====================================================
///
/// Información temporal mientras no existe
/// conexión con Firebase.
final List<TarjetaDashboardModelo> tarjetasDashboard = [
  TarjetaDashboardModelo(
    icono: Icons.wb_sunny,
    titulo: 'Clima',
    descripcion: '28°C - Soleado',
  ),

  TarjetaDashboardModelo(
    icono: Icons.water,
    titulo: 'Mareas',
    descripcion: 'Pleamar: 16:30 hrs',
  ),

  TarjetaDashboardModelo(
    icono: Icons.menu_book,
    titulo: 'Consejos',
    descripcion: 'Consejos para pesca de robalo',
  ),

  TarjetaDashboardModelo(
    icono: Icons.local_offer,
    titulo: 'Promociones',
    descripcion: '20% de descuento en carretes',
  ),

  TarjetaDashboardModelo(
    icono: Icons.phishing,
    titulo: 'Capturas',
    descripcion: 'No existen capturas registradas',
  ),
];
