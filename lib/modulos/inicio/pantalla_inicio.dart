import 'package:flutter/material.dart';

// Importamos los datos de las tarjetas del inicio.
import '../../compartido/datos/dashboard_mock.dart';

// Importamos el componente de las tarjetas.
import '../../compartido/widgets/tarjeta_dashboard.dart';

// Importamos nuestro logotipo reutilizable.
import '../../compartido/widgets/logo_tarpon.dart';

/// =====================================================
/// PANTALLA DE INICIO DE TARPON MX
/// =====================================================
///
/// Responsabilidades:
/// 1. Mostrar el nombre de la aplicación.
/// 2. Mostrar el logotipo oficial.
/// 3. Presentar las tarjetas informativas.
///
/// Esta pantalla no administra datos directamente.
/// Utiliza los datos de dashboard_mock.dart.
class PantallaInicio extends StatelessWidget {
  /// Constructor de la pantalla.
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura
    // principal de nuestra pantalla.
    return Scaffold(
      // Barra superior de la aplicación.
      appBar: AppBar(title: const Text('TARPON MX'), centerTitle: true),

      // SingleChildScrollView permite desplazar
      // la pantalla verticalmente.
      body: SingleChildScrollView(
        // Espacio entre los bordes de la pantalla
        // y los elementos de su interior.
        padding: const EdgeInsets.all(16),

        child: Column(
          // Los elementos se expanden horizontalmente
          // para aprovechar el espacio disponible.
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // =========================================
            // LOGOTIPO OFICIAL
            // =========================================

            const Center(child: LogoTarpon(ancho: 250, alto: 180)),

            // Espacio entre el logotipo y las tarjetas.
            const SizedBox(height: 20),

            // =========================================
            // TARJETAS INFORMATIVAS
            // =========================================

            // Recorremos la lista de tarjetas
            // definida en dashboard_mock.dart.
            //
            // El operador ... incorpora cada widget
            // generado a la lista de elementos.
            ...tarjetasDashboard.map((tarjeta) {
              return TarjetaDashboard(
                // Icono de la tarjeta.
                icono: tarjeta.icono,

                // Título de la tarjeta.
                titulo: tarjeta.titulo,

                // Descripción informativa.
                descripcion: tarjeta.descripcion,
              );
            }),
          ],
        ),
      ),
    );
  }
}
