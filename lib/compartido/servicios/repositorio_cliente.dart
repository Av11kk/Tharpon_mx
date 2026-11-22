import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

typedef FilaCliente = Map<String, dynamic>;

enum ArchivoCliente {
  capturas(
    'fecha',
    'id,especie_id,especie_texto,fecha,peso_kg,longitud_cm,lugar,notas,foto_path,especies(nombre)',
  ),
  notas('creado_en', 'id,titulo,contenido,creado_en'),
  reportes('creado_en', 'id,titulo,descripcion,estado,respuesta,creado_en');

  const ArchivoCliente(this.fecha, this.columnas);
  final String fecha, columnas;
}

String? formatoFoto(Uint8List bytes) {
  if (bytes.length < 12 || bytes.length > 5242880) return null;
  bool coincide(int inicio, List<int> firma) {
    for (var i = 0; i < firma.length; i++) {
      if (bytes[inicio + i] != firma[i]) return false;
    }
    return true;
  }

  if (coincide(0, [255, 216, 255])) return 'jpeg';
  if (coincide(0, [137, 80, 78, 71, 13, 10, 26, 10])) return 'png';
  if (coincide(0, [82, 73, 70, 70]) && coincide(8, [87, 69, 66, 80])) {
    return 'webp';
  }
  return null;
}

bool promocionVigente(FilaCliente fila, DateTime ahora) {
  final inicio = DateTime.parse(fila['inicio'] as String);
  final fin = DateTime.parse(fila['fin'] as String);
  return !ahora.isBefore(inicio) &&
      !ahora.isAfter(fin) &&
      fila['productos'] != null;
}

class RepositorioCliente {
  Future<List<FilaCliente>> puntosPesca() => _paginar(
    (a, b) => _cliente
        .from('puntos_pesca')
        .select(
          'id,nombre,descripcion,latitud,longitud,imagen_path,publicado,puntos_especies(especies(id,nombre,publicado))',
        )
        .eq('publicado', true)
        .eq('puntos_especies.especies.publicado', true)
        .order('nombre', ascending: true)
        .order('id')
        .range(a, b),
  );

  RepositorioCliente(this._cliente, this.usuarioId);
  final SupabaseClient _cliente;
  final String usuarioId;
  static const pagina = 100;
  final _firmas = <(String, String), (DateTime, Future<String>)>{};

  void _sesion() {
    if (_cliente.auth.currentSession?.user.id != usuarioId) {
      throw StateError('La sesión cambió.');
    }
  }

  String? get correo {
    final usuario = _cliente.auth.currentSession?.user;
    return usuario?.id == usuarioId ? usuario?.email : null;
  }

  Future<List<FilaCliente>> _paginar(
    Future<List<FilaCliente>> Function(int, int) consulta,
  ) async {
    final filas = <FilaCliente>[];
    while (true) {
      _sesion();
      final inicio = filas.length;
      final parte = await consulta(inicio, inicio + pagina - 1);
      filas.addAll(parte);
      if (parte.length < pagina) return filas;
    }
  }

  Future<FilaCliente> perfil() async {
    _sesion();
    return _cliente
        .from('perfiles')
        .select('id,nombre,rol,avatar_path')
        .eq('id', usuarioId)
        .eq('activo', true)
        .single();
  }

  Future<void> guardarPerfil(
    String nombre, {
    Uint8List? foto,
    String? anterior,
  }) async {
    final ruta = foto == null ? null : await _subir(foto);
    await _conFoto(ruta, anterior, () async {
      _sesion();
      var consulta = _cliente
          .from('perfiles')
          .update({'nombre': nombre, 'avatar_path': ?ruta})
          .eq('id', usuarioId);
      if (ruta != null) {
        consulta = anterior == null
            ? consulta.isFilter('avatar_path', null)
            : consulta.eq('avatar_path', anterior);
      }
      await consulta.select('id').single();
    });
  }

  Future<List<FilaCliente>> archivos(ArchivoCliente tipo) => _paginar(
    (a, b) => _cliente
        .from(tipo.name)
        .select(tipo.columnas)
        .eq('usuario_id', usuarioId)
        .order(tipo.fecha)
        .order('id')
        .range(a, b),
  );

  Future<void> guardarNota(String titulo, String contenido, {String? id}) =>
      _guardar(ArchivoCliente.notas, {
        'titulo': titulo,
        'contenido': contenido,
      }, id);

  Future<void> crearReporte(String titulo, String descripcion) => _guardar(
    ArchivoCliente.reportes,
    {'titulo': titulo, 'descripcion': descripcion},
    null,
  );

  Future<void> guardarCaptura(
    FilaCliente datos, {
    String? id,
    Uint8List? foto,
    String? anterior,
  }) async {
    final ruta = foto == null ? null : await _subir(foto);
    final campos = {
      for (final k in [
        'especie_id',
        'especie_texto',
        'fecha',
        'peso_kg',
        'longitud_cm',
        'lugar',
        'notas',
      ])
        k: datos[k],
      'foto_path': ?ruta,
    };
    await _conFoto(
      ruta,
      anterior,
      () =>
          _guardar(ArchivoCliente.capturas, campos, id, fotoAnterior: anterior),
    );
  }

  Future<void> _guardar(
    ArchivoCliente tipo,
    FilaCliente datos,
    String? id, {
    String? fotoAnterior,
  }) async {
    _sesion();
    final tabla = _cliente.from(tipo.name);
    if (id == null) {
      await tabla
          .insert({...datos, 'usuario_id': usuarioId})
          .select('id')
          .single();
    } else {
      var consulta = tabla
          .update(datos)
          .eq('usuario_id', usuarioId)
          .eq('id', id);
      if (tipo == ArchivoCliente.capturas && datos.containsKey('foto_path')) {
        consulta = fotoAnterior == null
            ? consulta.isFilter('foto_path', null)
            : consulta.eq('foto_path', fotoAnterior);
      }
      await consulta.select('id').single();
    }
  }

  Future<void> borrar(ArchivoCliente tipo, String id) async {
    if (tipo == ArchivoCliente.reportes) throw ArgumentError.value(tipo);
    _sesion();
    final fila = await _cliente
        .from(tipo.name)
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('id', id)
        .select(tipo == ArchivoCliente.capturas ? 'id,foto_path' : 'id')
        .single();
    final foto = fila['foto_path'] as String?;
    if (foto != null) await _limpiarFoto(foto);
  }

  Future<List<FilaCliente>> especies() => _paginar(
    (a, b) => _cliente
        .from('especies')
        .select(
          'id,nombre,nombre_cientifico,descripcion,habitat,recomendaciones,imagen_path',
        )
        .eq('publicado', true)
        .order('nombre', ascending: true)
        .order('id')
        .range(a, b),
  );

  Future<List<FilaCliente>> categorias({required bool equipo}) => _paginar(
    (a, b) => _cliente
        .from(equipo ? 'categorias_productos' : 'categorias_consejos')
        .select('id,nombre,descripcion')
        .eq('publicado', true)
        .order('orden', ascending: true)
        .order('id')
        .range(a, b),
  );

  Future<List<FilaCliente>> consejos() => _paginar(
    (a, b) => _cliente
        .from('consejos')
        .select(
          'id,categoria_id,titulo,resumen,contenido,imagen_path,categorias_consejos!inner(publicado)',
        )
        .eq('publicado', true)
        .eq('categorias_consejos.publicado', true)
        .order('creado_en')
        .order('id')
        .range(a, b),
  );

  Future<Set<String>> favoritos() async => (await _paginar(
    (a, b) => _cliente
        .from('favoritos_consejos')
        .select('consejo_id')
        .eq('usuario_id', usuarioId)
        .order('consejo_id')
        .range(a, b),
  )).map((fila) => fila['consejo_id'] as String).toSet();

  Future<void> favorito(String id, bool guardar) async {
    _sesion();
    final tabla = _cliente.from('favoritos_consejos');
    if (guardar) {
      await tabla.upsert(
        {'usuario_id': usuarioId, 'consejo_id': id},
        onConflict: 'usuario_id,consejo_id',
        ignoreDuplicates: true,
      );
    } else {
      await tabla.delete().eq('usuario_id', usuarioId).eq('consejo_id', id);
    }
  }

  static const _producto =
      'id,categoria_id,nombre,marca,modelo,descripcion,precio,existencias,imagenes_productos(ruta,orden),categorias_productos!inner(publicado)';

  Future<List<FilaCliente>> productos() => _paginar(
    (a, b) => _cliente
        .from('productos')
        .select(_producto)
        .eq('publicado', true)
        .eq('categorias_productos.publicado', true)
        .order('nombre', ascending: true)
        .order('id')
        .range(a, b),
  );

  Future<List<FilaCliente>> promociones() {
    final ahora = DateTime.now().toUtc().toIso8601String();
    return _paginar(
      (a, b) => _cliente
          .from('promociones')
          .select(
            'id,titulo,precio_oferta,inicio,fin,banner_path,productos!inner($_producto)',
          )
          .eq('publicado', true)
          .eq('productos.publicado', true)
          .eq('productos.categorias_productos.publicado', true)
          .lte('inicio', ahora)
          .gte('fin', ahora)
          .order('orden', ascending: true)
          .order('id')
          .range(a, b),
    );
  }

  Future<String?> whatsapp() async {
    _sesion();
    final fila = await _cliente
        .from('configuracion')
        .select('whatsapp')
        .eq('id', 1)
        .maybeSingle();
    return fila?['whatsapp'] as String?;
  }

  Future<String> firmar(
    String ruta, {
    required bool personal,
    bool renovar = false,
  }) {
    _sesion();
    if (personal && !ruta.startsWith('$usuarioId/')) {
      throw ArgumentError('Ruta personal inválida.');
    }
    final bucket = personal ? 'personal' : 'catalogo';
    final clave = (bucket, ruta);
    final ahora = DateTime.now();
    _firmas.removeWhere((_, firma) => !ahora.isBefore(firma.$1));
    final guardada = _firmas[clave];
    if (!renovar && guardada != null) return guardada.$2;
    final firma = _cliente.storage.from(bucket).createSignedUrl(ruta, 300);
    _firmas[clave] = (ahora.add(const Duration(minutes: 4)), firma);
    return firma;
  }

  Future<String> _subir(Uint8List bytes) async {
    _sesion();
    final formato = formatoFoto(bytes);
    if (formato == null) {
      throw const FormatException('Selecciona JPG, PNG o WebP de hasta 5 MB.');
    }
    final azar = Random.secure();
    final sufijo = List.generate(
      16,
      (_) => azar.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final ruta = '$usuarioId/$sufijo.$formato';
    await _cliente.storage
        .from('personal')
        .uploadBinary(
          ruta,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$formato'),
        );
    return ruta;
  }

  Future<void> _conFoto(
    String? nueva,
    String? anterior,
    Future<void> Function() guardar,
  ) async {
    try {
      await guardar();
    } on PostgrestException catch (error) {
      // SQLSTATEs de datos, restricciones y permisos confirman rechazo.
      final codigo = error.code ?? '';
      if (nueva != null &&
          (codigo == 'PGRST116' ||
              RegExp(r'^(22|23|42)[A-Z0-9]{3}$').hasMatch(codigo))) {
        await _limpiarFoto(nueva);
      }
      rethrow;
    }
    if (nueva != null && anterior != null && anterior != nueva) {
      await _limpiarFoto(anterior);
    }
  }

  Future<void> _limpiarFoto(String ruta) async {
    if (!ruta.startsWith('$usuarioId/')) return;
    try {
      _sesion();
      await _cliente.storage.from('personal').remove([ruta]);
      _firmas.remove(('personal', ruta));
    } catch (_) {
      // La fila ya fue modificada. No se revierte ante un fallo de limpieza.
    }
  }
}
