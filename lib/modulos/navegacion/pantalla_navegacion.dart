import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../compartido/servicios/repositorio_cliente.dart';
import '../../compartido/servicios/servicio_autenticacion.dart';
import '../../compartido/widgets/selector_zona.dart';
import '../../compartido/widgets/superficie_cristal.dart';
import '../../nucleo/colores_app.dart';
import '../../compartido/widgets/encabezado_navegacion.dart';
import '../../compartido/widgets/panel_geografico.dart';
import '../../nucleo/modulo_app.dart';
import '../condiciones/pantalla_condiciones.dart';
import '../../compartido/widgets/fondo_atmosferico.dart';
import '../consejos/pantalla_consejos.dart';
import '../equipamiento/pantalla_equipamiento.dart';
import '../especies/pantalla_especies.dart';
import '../inicio/pantalla_inicio.dart';
import '../mapa/pantalla_mapa.dart';
import '../perfil/pantalla_perfil.dart';

class PantallaNavegacion extends StatefulWidget {
  const PantallaNavegacion({
    super.key,
    this.perfil,
    this.cerrarSesion,
    this.cliente,
    this.entorno,
  });

  final PerfilAutenticado? perfil;
  final Future<void> Function()? cerrarSesion;
  final SupabaseClient? cliente;
  final EntornoGeo? entorno;

  @override
  State<PantallaNavegacion> createState() => _PantallaNavegacionState();
}

class _PantallaNavegacionState extends State<PantallaNavegacion> {
  ModuloApp _modulo = ModuloApp.inicio;
  bool _promociones = false;
  bool _explorar = false;
  final _visitados = {ModuloApp.inicio, ModuloApp.clima};
  late final RepositorioCliente? _repo =
      widget.cliente == null || widget.perfil == null
      ? null
      : RepositorioCliente(widget.cliente!, widget.perfil!.id);
  late final _entorno = widget.entorno ?? EntornoGeo();
  late final _puntos = ValueNotifier<Future<List<FilaCliente>>>(
    (_repo?.puntosPesca() ?? Future.value(<FilaCliente>[]))..ignore(),
  );

  @override
  void dispose() {
    if (widget.entorno == null) _entorno.dispose();
    _puntos.dispose();
    super.dispose();
  }

  void _seleccionar(ModuloApp modulo, {bool promociones = false}) {
    if (modulo == ModuloApp.mareas) modulo = ModuloApp.clima;
    if (!_explorar && _modulo == modulo && _promociones == promociones) return;
    setState(() {
      _explorar = false;
      _modulo = modulo;
      _visitados.add(modulo);
      _promociones = promociones;
    });
  }

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPerfil(
          perfil: widget.perfil,
          repo: _repo,
          cerrarSesion: widget.cerrarSesion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: ValueListenableBuilder(
        valueListenable: _entorno.localidad,
        builder: (_, lugar, _) => EncabezadoNavegacion(
          abrirZona: () => configurarZona(context, _entorno),
          abrirPerfil: _abrirPerfil,
          localidad: lugar.nombre,
        ),
      ),
    ),
    bottomNavigationBar: GlassTabBar.bottom(
      selectedIndex: _explorar
          ? 4
          : switch (_modulo) {
              ModuloApp.clima || ModuloApp.mareas => 1,
              ModuloApp.mapa => 2,
              ModuloApp.equipo => 3,
              ModuloApp.especies || ModuloApp.consejos => 4,
              _ => 0,
            },
      onTabSelected: (i) {
        if (i == 4) {
          setState(() => _explorar = true);
        } else {
          _seleccionar(
            [
              ModuloApp.inicio,
              ModuloApp.clima,
              ModuloApp.mapa,
              ModuloApp.equipo,
            ][i],
          );
        }
      },
      horizontalPadding: 10,
      verticalPadding: 10,
      selectedIconColor: ColoresApp.acento,
      selectedLabelColor: ColoresApp.textoPrincipal,
      unselectedIconColor: ColoresApp.textoSecundario,
      unselectedLabelColor: ColoresApp.textoSecundario,
      labelFontSize: 10,
      iconSize: 22,
      settings: SuperficieCristal.material,
      quality: GlassQuality.premium,
      tabs: const [
        GlassTab(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        GlassTab(icon: Icon(Icons.cloud_outlined), label: 'Condiciones'),
        GlassTab(icon: Icon(Icons.map_outlined), label: 'Mapa'),
        GlassTab(icon: Icon(Icons.storefront_outlined), label: 'Equipo'),
        GlassTab(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
      ],
    ),
    body: FondoAtmosferico(
      child: IndexedStack(
        index: _explorar ? ModuloApp.values.length : _modulo.index,
        children: [
          PantallaInicio(
            entorno: _entorno,
            puntos: _puntos,
            onAbrirModulo: _seleccionar,
            onAbrirPromociones: () =>
                _seleccionar(ModuloApp.equipo, promociones: true),
          ),
          if (_visitados.contains(ModuloApp.especies))
            PantallaEspecies(repo: _repo)
          else
            const SizedBox.shrink(),
          PantallaCondiciones(entorno: _entorno),
          const SizedBox.shrink(), // Alias histórico: Mareas abre Condiciones.
          if (_visitados.contains(ModuloApp.mapa))
            PantallaMapa(entorno: _entorno, puntos: _puntos, repo: _repo)
          else
            const SizedBox.shrink(),
          if (_visitados.contains(ModuloApp.equipo))
            PantallaEquipamiento(mostrarPromociones: _promociones, repo: _repo)
          else
            const SizedBox.shrink(),
          if (_visitados.contains(ModuloApp.consejos))
            PantallaConsejos(repo: _repo)
          else
            const SizedBox.shrink(),
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              Text(
                'Explorar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Conoce tu entorno. Prepara tu próxima salida.'),
              const SizedBox(height: 24),
              SuperficieCristal(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.set_meal_outlined),
                      title: const Text('Especies de peces'),
                      subtitle: const Text('Guía de especies locales'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _seleccionar(ModuloApp.especies),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline),
                      title: const Text('Consejos'),
                      subtitle: const Text('Técnicas y recomendaciones'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _seleccionar(ModuloApp.consejos),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
