import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../nucleo/colores_app.dart';
import '../servicios/servicio_geografico.dart';
import 'controles_app.dart';

class GraficaCondiciones extends StatelessWidget {
  const GraficaCondiciones({
    super.key,
    required this.titulo,
    required this.pasos,
    required this.campo,
    required this.unidad,
    this.color = ColoresApp.etiqueta,
    this.compacto = false,
  });
  final String titulo, campo, unidad;
  final List<PasoGeo> pasos;
  final Color color;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final valores = pasos.map((p) => p.numero(campo)).toList();
    final disponibles = valores.whereType<double>().toList();
    if (disponibles.isEmpty) {
      return TarjetaApp(child: Text('$titulo · Sin datos'));
    }
    final min = disponibles.reduce(math.min);
    final max = disponibles.reduce(math.max);
    final margen = math.max((max - min) * .18, unidad.trim() == '%' ? 5.0 : .2);
    final minY = min - margen;
    final maxY = max + margen;
    final estilo = Theme.of(context).textTheme;
    return TarjetaApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(titulo, style: estilo.titleMedium),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mín. ${medidaGeo(min, unidad, decimales: 1)}',
                  style: estilo.bodySmall,
                ),
              ),
              Text(
                'Máx. ${medidaGeo(max, unidad, decimales: 1)}',
                style: estilo.bodySmall,
              ),
            ],
          ),
          Semantics(
            label:
                '$titulo. Mínimo $min$unidad, máximo $max$unidad. Desliza para consultar cada hora o abre los valores por hora.',
            child: SizedBox(
              height: compacto ? 130 : 164,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, pasos.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  clipData: const FlClipData.all(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 3,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: .08),
                      strokeWidth: 1,
                      dashArray: [3, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: (maxY - minY) / 3,
                        minIncluded: false,
                        maxIncluded: false,
                        getTitlesWidget: (v, meta) => Text(
                          v.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColoresApp.textoSecundario,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: math
                            .max(1, (pasos.length - 1) / 3)
                            .ceilToDouble(),
                        getTitlesWidget: (v, meta) {
                          final i = v.round();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              i >= 0 && i < pasos.length
                                  ? horaGeo(pasos[i].hora)
                                  : '',
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColoresApp.textoSecundario,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF243732),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              '${horaGeo(pasos[s.x.round()].hora)}\n${medidaGeo(s.y, unidad, decimales: 1)}',
                              const TextStyle(
                                color: ColoresApp.textoPrincipal,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < valores.length; i++)
                          valores[i] == null
                              ? FlSpot.nullSpot
                              : FlSpot(i.toDouble(), valores[i]!),
                      ],
                      color: color,
                      barWidth: 2.5,
                      isCurved: false,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: disponibles.length == 1),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: .26),
                            color.withValues(alpha: .01),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          Text(
            'Desliza sobre la curva para ver hora y valor',
            style: estilo.labelSmall,
          ),
          if (!compacto)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Valores por hora'),
              children: [
                for (final paso in pasos)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${diaGeo(paso.hora)} · ${horaGeo(paso.hora)}',
                          ),
                        ),
                        Text(
                          medidaGeo(paso.numero(campo), unidad, decimales: 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
