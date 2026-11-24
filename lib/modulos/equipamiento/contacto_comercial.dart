import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../compartido/widgets/contenido_cliente.dart';
import '../../compartido/widgets/controles_app.dart';

enum ConsultaComercial { general, producto, promocion }

String mensajeComercial(
  ConsultaComercial tipo, {
  String? nombre,
  String? modelo,
  String? precio,
}) {
  final base = switch (tipo) {
    ConsultaComercial.general => 'Hola, me gustaría recibir información sobre los artículos de pesca disponibles en Tarpon MX.',
    ConsultaComercial.producto =>
      'Hola, me interesa el siguiente producto de Tarpon MX: $nombre. ¿Podrían proporcionarme más información sobre su disponibilidad?',
    ConsultaComercial.promocion =>
      'Hola, me interesa la promoción de $nombre publicada en Tarpon MX. ¿Continúa disponible?',
  };
  return [
    base,
    if (modelo != null && modelo.isNotEmpty) 'Modelo: $modelo.',
    if (precio != null && precio.isNotEmpty) 'Precio: $precio.',
  ].join('\n');
}

Uri? enlaceComercial(String? telefono, String mensaje) {
  if (telefono == null ||
      !RegExp(r'^\+?[0-9\s().-]+$').hasMatch(telefono.trim())) {
    return null;
  }
  var numero = telefono.replaceAll(RegExp(r'[^0-9]'), '');
  if (numero.length == 10 && !telefono.trim().startsWith('+')) {
    numero = '52$numero';
  }
  if (!RegExp(r'^[1-9][0-9]{9,14}$').hasMatch(numero)) return null;
  return Uri.https('wa.me', '/$numero', {'text': mensaje});
}

class ContactoComercial extends StatelessWidget {
  const ContactoComercial({
    super.key,
    required this.telefono,
    required this.mensaje,
  });
  final String? telefono;
  final String mensaje;

  Future<void> _abrir(BuildContext context, Uri destino) async {
    try {
      if (await launchUrl(destino, mode: LaunchMode.platformDefault)) return;
    } catch (_) {
      // Algunos dispositivos no tienen aplicación para abrir el vínculo.
    }
    if (context.mounted) {
      avisoCliente(
        context,
        'No se pudo abrir WhatsApp. Instala la aplicación o usa un navegador compatible.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destino = enlaceComercial(telefono, mensaje);
    return ListaCliente(
      children: [
        const EncabezadoApp(titulo: 'Mensaje precargado'),
        TarjetaApp(child: SelectableText(mensaje)),
        if (destino == null)
          const Text('El número comercial todavía no está configurado.'),
        BotonPrincipal(
          texto: 'Abrir WhatsApp',
          alPulsar: destino == null ? null : () => _abrir(context, destino),
        ),
      ],
    );
  }
}
