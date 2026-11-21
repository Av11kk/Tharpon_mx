import 'package:flutter_test/flutter_test.dart';

import 'package:tarpon_mx/compartido/modelos/marea.dart';
import 'package:tarpon_mx/compartido/modelos/reporte_mareas.dart';

/// Pruebas del modelo de mareas.
void main() {
  test('Obtiene el próximo evento de marea', () {
    // Creamos una fecha fija para la prueba.
    final ahora = DateTime(2026, 11, 19, 8);

    // Creamos eventos ficticios.
    //
    // Estos valores sirven únicamente para
    // comprobar el funcionamiento del código.
    final eventos = [
      Marea(
        tipo: TipoMarea.pleamar,
        fechaHora: DateTime(2026, 11, 19, 7),
        ubicacion: 'Ciudad del Carmen',
        fuente: 'Prueba',
      ),

      Marea(
        tipo: TipoMarea.bajamar,
        fechaHora: DateTime(2026, 11, 19, 13),
        ubicacion: 'Ciudad del Carmen',
        fuente: 'Prueba',
      ),

      Marea(
        tipo: TipoMarea.pleamar,
        fechaHora: DateTime(2026, 11, 19, 19),
        ubicacion: 'Ciudad del Carmen',
        fuente: 'Prueba',
      ),
    ];

    // Agrupamos los eventos.
    final reporte = ReporteMareas(
      ubicacion: 'Ciudad del Carmen',
      fechaConsulta: ahora,
      eventos: eventos,
    );

    // Solicitamos el evento más cercano.
    final resultado = reporte.proximaMarea(ahora);

    // Verificamos que sea la bajamar
    // programada a las 13:00.
    expect(resultado?.tipo, TipoMarea.bajamar);

    expect(resultado?.fechaHora.hour, 13);
  });
}
