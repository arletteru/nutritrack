// Card de evolución de peso para el dashboard del paciente.
// Usa fl_chart ^0.70.1 para la gráfica de línea.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../consultation/presentation/providers/weight_history_provider.dart';

class WeightProgressCard extends ConsumerWidget {
  const WeightProgressCard({super.key, required this.patientUid});
  final String patientUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWeightHistoryProvider(patientUid));
    final goalAsync = ref.watch(watchWeightGoalProvider(patientUid));

    return historyAsync.when(
      loading: () => _CardShell(
        child: const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (entries) {
        // Con menos de 2 consultas no hay gráfica útil
        if (entries.length < 2) {
          return _CardShell(
            child: _EmptyState(entriesCount: entries.length),
          );
        }

        final goal = goalAsync.value;
        final first = entries.first.weight;
        final last = entries.last.weight;
        final diff = last - first;
        final lastImc = entries.last.imc;

        // Progreso hacia la meta (0.0 a 1.0)
        double? progress;
        if (goal != null && first != goal) {
          progress = ((first - last) / (first - goal)).clamp(0.0, 1.0);
        }

        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mi progreso',
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant)),
                        Text('Evolución de peso',
                            style: context.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  // Badge diferencia
                  _DiffBadge(diff: diff),
                ],
              ),

              const SizedBox(height: 16),

              // ── Gráfica ────────────────────────────────────────────────────
              SizedBox(
                height: 160,
                child: _WeightChart(
                  entries: entries,
                  goal: goal,
                  primaryColor: context.colors.primary,
                  gridColor:
                      context.colors.onSurface.withOpacity(0.06),
                  textColor: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // ── Métricas ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Peso inicial',
                      value: '${first.toStringAsFixed(1)} kg',
                      sub: _formatDate(entries.first.date),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'Peso actual',
                      value: '${last.toStringAsFixed(1)} kg',
                      sub: 'Última consulta',
                      highlight: true,
                    ),
                  ),
                  if (lastImc != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricTile(
                        label: 'IMC actual',
                        value: lastImc.toStringAsFixed(1),
                        sub: _imcLabel(lastImc),
                      ),
                    ),
                  ],
                ],
              ),

              // ── Barra de progreso hacia la meta ────────────────────────────
              if (goal != null && progress != null) ...[
                const SizedBox(height: 14),
                _GoalProgressBar(
                  goal: goal,
                  progress: progress,
                  consultationsCount: entries.length,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      DateFormat('MMM yyyy', 'es_MX').format(d);

  String _imcLabel(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25.0) return 'Normopeso';
    if (imc < 30.0) return 'Sobrepeso';
    return 'Obesidad';
  }
}

// ── Gráfica fl_chart ──────────────────────────────────────────────────────────
class _WeightChart extends StatelessWidget {
  const _WeightChart({
    required this.entries,
    required this.primaryColor,
    required this.gridColor,
    required this.textColor,
    this.goal,
  });

  final List<WeightEntry> entries;
  final double? goal;
  final Color primaryColor;
  final Color gridColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final weights = entries.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);

    // Rango del eje Y — deja margen arriba y abajo
    final goalMin = goal != null && goal! < minW ? goal! : minW;
    final yMin = (goalMin - 2).floorToDouble();
    final yMax = (maxW + 2).ceilToDouble();

    // Puntos de la línea principal
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    // Puntos de la línea de meta (horizontal)
    final goalSpots = goal != null
        ? [
            FlSpot(0, goal!),
            FlSpot((entries.length - 1).toDouble(), goal!),
          ]
        : <FlSpot>[];

    return LineChart(
      LineChartData(
        minY: yMin,
        maxY: yMax,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (yMax - yMin) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: gridColor,
            strokeWidth: 0.8,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (yMax - yMin) / 4,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(fontSize: 10, color: textColor),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                // Solo muestra primera y última etiqueta
                if (idx != 0 && idx != entries.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('MMM', 'es_MX').format(entries[idx].date),
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              if (s.barIndex == 1) {
                // Línea meta
                return LineTooltipItem(
                  'Meta: ${s.y.toStringAsFixed(1)} kg',
                  TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }
              return LineTooltipItem(
                '${s.y.toStringAsFixed(1)} kg',
                TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          // ── Línea principal de peso ─────────────────────────────────────
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: .08),
            ),
          ),

          // ── Línea de meta (punteada) ────────────────────────────────────
          if (goalSpots.isNotEmpty)
            LineChartBarData(
              spots: goalSpots,
              isCurved: false,
              color: Colors.grey.shade400,
              barWidth: 1.2,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );
}

class _DiffBadge extends StatelessWidget {
  const _DiffBadge({required this.diff});
  final double diff;

  @override
  Widget build(BuildContext context) {
    final lost = diff < 0;
    final color =
        lost ? context.nutri.success : context.colors.error;
    final bgColor = lost
        ? context.nutri.successContainer
        : context.colors.errorContainer;
    final icon =
        lost ? Icons.trending_down_rounded : Icons.trending_up_rounded;
    final label =
        '${lost ? '' : '+'}${diff.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.sub,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String sub;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(context.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: context.textTheme.titleMedium?.copyWith(
                  color: highlight
                      ? context.nutri.success
                      : context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                )),
            Text(sub,
                style: context.textTheme.labelSmall?.copyWith(
                    color: highlight
                        ? context.nutri.success
                        : context.colors.onSurfaceVariant)),
          ],
        ),
      );
}

class _GoalProgressBar extends StatelessWidget {
  const _GoalProgressBar({
    required this.goal,
    required this.progress,
    required this.consultationsCount,
  });

  final double goal;
  final double progress;
  final int consultationsCount;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined,
                  size: 14,
                  color: context.colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Meta: ${goal.toStringAsFixed(1)} kg  ·  $consultationsCount consultas',
                style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.nutri.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                  context.nutri.success),
            ),
          ),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.entriesCount});
  final int entriesCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(Icons.show_chart_outlined,
                size: 32,
                color: context.colors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Evolución de peso',
                      style: context.textTheme.titleSmall),
                  Text(
                    entriesCount == 0
                        ? 'Tu progreso aparecerá después de tu primera consulta.'
                        : 'Necesitas al menos 2 consultas para ver la gráfica.',
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
