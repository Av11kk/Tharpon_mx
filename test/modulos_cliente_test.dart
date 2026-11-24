import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarpon_mx/compartido/servicios/repositorio_cliente.dart';
import 'package:tarpon_mx/compartido/widgets/catalogo_cliente.dart';
import 'package:tarpon_mx/modulos/capturas/pantalla_capturas.dart';
import 'package:tarpon_mx/modulos/equipamiento/contacto_comercial.dart';
import 'package:tarpon_mx/nucleo/tema_app.dart';

void main() {
  testWidgets('El archivo muestra un error recuperable y permite reintentar', (
    tester,
  ) async {
    final repo = _RepositorioPrueba()..falla = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: PantallaArchivo(repo: repo, tipo: ArchivoCliente.reportes),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cargar la información.'), findsOneWidget);
    repo.falla = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes registros.'), findsOneWidget);
  });

  test('Valida tamaño, firmas de imagen y medidas', () {
    expect(
      formatoFoto(
        Uint8List.fromList([255, 216, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
      ),
      'jpeg',
    );
    expect(formatoFoto(Uint8List(5242881)), isNull);
    expect(formatoFoto(Uint8List(12)), isNull);
    expect(medidaCaptura('1,25'), 1.25);
    expect(medidaCaptura(''), isNull);
    expect(() => medidaCaptura('-1'), throwsFormatException);
    expect(() => medidaCaptura('NaN'), throwsFormatException);
  });

  test('Promoción vigente y disponibilidad de inventario', () {
    final fila = {
      'inicio': '2026-11-01T00:00:00Z',
      'fin': '2026-11-30T00:00:00Z',
      'productos': {'existencias': 0},
    };
    expect(promocionVigente(fila, DateTime.utc(2026, 11, 22)), isTrue);
    expect(promocionVigente(fila, DateTime.utc(2026, 12)), isFalse);
    expect(
      promocionVigente({
        ...fila,
        'productos': null,
      }, DateTime.utc(2026, 11, 22)),
      isFalse,
    );
    expect(disponibilidad({'existencias': 0}), 'Agotado');
    expect(disponibilidad({'existencias': 1}), 'Disponible');
    expect(precioMx(350.5), 'MXN 350.50');
  });

  test('Construye el mensaje y solo admite un número comercial válido', () {
    final mensaje = mensajeComercial(
      ConsultaComercial.promocion,
      nombre: 'Caña & carrete',
      modelo: 'Modelo 1',
      precio: 'MXN 100.00',
    );
    final uri = enlaceComercial('55 0102 0304', mensaje);
    expect(uri?.host, 'wa.me');
    expect(uri?.path, '/525501020304');
    expect(uri?.queryParameters['text'], mensaje);
    expect(mensaje, contains('Caña & carrete'));
    expect(mensaje, contains('MXN 100.00'));
    expect(enlaceComercial(null, mensaje), isNull);
    expect(enlaceComercial('https://example.com/1234567890', mensaje), isNull);
  });

  testWidgets(
    'Notas valida y persiste creación, edición y eliminación en el repositorio simulado',
    (tester) async {
      final repo = _RepositorioPrueba();
      await tester.pumpWidget(
        MaterialApp(
          theme: TemaApp.oscuro,
          home: PantallaArchivo(repo: repo, tipo: ArchivoCliente.notas),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes registros.'), findsOneWidget);
      await tester.tap(find.text('Nueva nota'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Completa este campo.'), findsNWidgets(2));
      await tester.enterText(find.byType(TextFormField).at(0), 'Jornada');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Contenido personal',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repo.filas.single['titulo'], 'Jornada');
      await tester.tap(find.byTooltip('Opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Jornada editada',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repo.filas.single['titulo'], 'Jornada editada');
      await tester.tap(find.byTooltip('Opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      expect(repo.filas, isEmpty);
    },
  );

  testWidgets('Consejos busca y sincroniza favoritos con su detalle', (
    tester,
  ) async {
    final repo = _RepositorioPrueba();
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.oscuro,
        home: Scaffold(
          body: CatalogoCliente(repo: repo, tipo: TipoCatalogo.consejos),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nudo');
    await tester.pumpAndSettle();
    expect(find.text('Nudo de prueba'), findsOneWidget);
    await tester.tap(find.text('Nudo de prueba'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Guardar favorito'));
    await tester.pumpAndSettle();
    expect(repo.guardados, {'consejo'});
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar favorito'), findsOneWidget);
    await tester.tap(find.text('Mis favoritos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quitar favorito'));
    await tester.pumpAndSettle();
    expect(find.text('No hay consejos favoritos que mostrar.'), findsOneWidget);
  });
}

class _RepositorioPrueba implements RepositorioCliente {
  bool falla = false;
  final filas = <FilaCliente>[];
  final guardados = <String>{};
  @override
  Future<List<FilaCliente>> archivos(ArchivoCliente tipo) async {
    if (falla) throw StateError('Error simulado');
    return [...filas];
  }

  @override
  Future<void> guardarNota(
    String titulo,
    String contenido, {
    String? id,
  }) async {
    final fila = {
      'id': id ?? 'nota',
      'titulo': titulo,
      'contenido': contenido,
      'creado_en': '2026-11-22T00:00:00Z',
    };
    if (id == null) {
      filas.add(fila);
    } else {
      filas[filas.indexWhere((f) => f['id'] == id)] = fila;
    }
  }

  @override
  Future<void> borrar(ArchivoCliente tipo, String id) async {
    filas.removeWhere((f) => f['id'] == id);
  }

  @override
  Future<List<FilaCliente>> consejos() async => [
    {
      'id': 'consejo',
      'titulo': 'Nudo de prueba',
      'contenido': 'Ejemplo para pruebas',
      'categoria_id': 'nudos',
    },
  ];
  @override
  Future<List<FilaCliente>> categorias({required bool equipo}) async => [
    {'id': 'nudos', 'nombre': 'Categoría de prueba'},
  ];
  @override
  Future<Set<String>> favoritos() async => {...guardados};
  @override
  Future<void> favorito(String id, bool guardar) async {
    if (guardar) {
      guardados.add(id);
    } else {
      guardados.remove(id);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
