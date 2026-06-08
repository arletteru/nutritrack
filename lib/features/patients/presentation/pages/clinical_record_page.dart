// features/patients/presentation/pages/clinical_record_page.dart
//
// Página de expediente clínico del paciente para el nutriólogo.
// Muestra gráficas de evolución de peso, IMC y bioquímicos entre consultas.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../consultation/presentation/providers/clinical_history_provider.dart';

class ClinicalRecordPage extends ConsumerWidget {
  const ClinicalRecordPage({
    super.key,
    required this.patientId,
    required this.patientUid,
    required this.nutriologistId,
    required this.patientName,
  });

  final String patientId;
  final String patientUid;
  final String nutriologistId;
  final String patientName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchClinicalHistoryProvider(
      patientUid: patientUid,
      nutriologistId: nutriologistId,
      patientDocId: patientId,
    ));

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expediente clínico',
                style: context.textTheme.headlineMedium),
            Text(patientName,
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant)),
          ],
        ),
      ),
      body: historyAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(e.toString(),
                style: TextStyle(color: context.colors.error)),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(patientName: patientName);
          }
          if (entries.length < 2) {
            return _SingleConsultState(entry: entries.first);
          }
          return _ClinicalBody(entries: entries);
        },
      ),
    );
  }
}

// ── Cuerpo principal ──────────────────────────────────────────────────────────
class _ClinicalBody extends StatelessWidget {
  const _ClinicalBody({required this.entries});
  final List<ClinicalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final labels = entries
        .map((e) => DateFormat('MMM yy', 'es_MX').format(e.date))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Resumen de última consulta ──────────────────────────────────────
        _SummaryCards(entry: entries.last),
        const SizedBox(height: 20),

        // ── Gráfica de peso ─────────────────────────────────────────────────
        if (entries.any((e) => e.weight != null)) ...[
          _ChartCard(
            title: 'Evolución de peso',
            icon: Icons.monitor_weight_outlined,
            unit: 'kg',
            child: _LineChartWidget(
              spots: entries
                  .asMap()
                  .entries
                  .where((e) => e.value.weight != null)
                  .map((e) => FlSpot(
                      e.key.toDouble(), e.value.weight!))
                  .toList(),
              labels: labels,
              color: context.colors.primary,
              unit: 'kg',
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Gráfica de IMC ──────────────────────────────────────────────────
        if (entries.any((e) => e.imc != null)) ...[
          _ChartCard(
            title: 'Evolución de IMC',
            icon: Icons.straighten_outlined,
            unit: 'IMC',
            child: _ImcChart(entries: entries, labels: labels),
          ),
          const SizedBox(height: 16),
        ],

        // ── Gráfica de glucosa ──────────────────────────────────────────────
        if (entries.any((e) => e.glucose != null)) ...[
          _ChartCard(
            title: 'Glucosa basal',
            icon: Icons.bloodtype_outlined,
            unit: 'mg/dL',
            referenceLines: const [
              _ReferenceLine(value: 100, label: 'Normal', color: Color(0xFF3B6D11)),
              _ReferenceLine(value: 126, label: 'Diabetes', color: Color(0xFFD85A30)),
            ],
            child: _LineChartWidget(
              spots: entries
                  .asMap()
                  .entries
                  .where((e) => e.value.glucose != null)
                  .map((e) => FlSpot(
                      e.key.toDouble(), e.value.glucose!))
                  .toList(),
              labels: labels,
              color: () {
                final lastGlu = entries.lastWhere((e) => e.glucose != null).glucose!;
                if (lastGlu > 126) return const Color(0xFFD85A30);
                if (lastGlu > 100) return const Color(0xFFBA7517);
                return const Color(0xFF3B6D11); // verde si está bien
              }(),
              unit: 'mg/dL',
              minY: 60,
              maxY: 200,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Gráfica de triglicéridos ────────────────────────────────────────
        if (entries.any((e) => e.triglycerides != null)) ...[
          _ChartCard(
            title: 'Triglicéridos',
            icon: Icons.water_drop_outlined,
            unit: 'mg/dL',
            referenceLines: const [
              _ReferenceLine(value: 150, label: 'Normal', color: Color(0xFF3B6D11)),
              _ReferenceLine(value: 200, label: 'Límite alto', color: Color(0xFFBA7517)),
            ],
            child: _LineChartWidget(
              spots: entries
                  .asMap()
                  .entries
                  .where((e) => e.value.triglycerides != null)
                  .map((e) => FlSpot(
                      e.key.toDouble(), e.value.triglycerides!))
                  .toList(),
              labels: labels,
              color: const Color(0xFFBA7517),
              unit: 'mg/dL',
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Tabla comparativa ───────────────────────────────────────────────
        _ComparisonTable(entries: entries, labels: labels),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Cards de resumen ──────────────────────────────────────────────────────────
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.entry});
  final ClinicalEntry entry;

  @override
  Widget build(BuildContext context) {
    final imc = entry.imc;
    String imcLabel = '';
    Color imcColor = context.colors.primary;
    if (imc != null) {
      if (imc < 18.5) { imcLabel = 'Bajo peso'; imcColor = context.colors.error; }
      else if (imc < 25) { imcLabel = 'Normopeso'; imcColor = context.nutri.success; }
      else if (imc < 30) { imcLabel = 'Sobrepeso'; imcColor = context.nutri.warning; }
      else { imcLabel = 'Obesidad'; imcColor = context.colors.error; }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Última consulta',
            style: context.textTheme.titleMedium),
        Text(
          DateFormat('d MMMM yyyy', 'es_MX').format(entry.date),
          style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Row(children: [
          if (entry.weight != null)
            Expanded(child: _MetricCard(
              label: 'Peso',
              value: '${entry.weight!.toStringAsFixed(1)} kg',
            )),
          if (entry.weight != null) const SizedBox(width: 8),
          if (imc != null)
            Expanded(child: _MetricCard(
              label: 'IMC',
              value: imc.toStringAsFixed(1),
              sub: imcLabel,
              color: imcColor,
            )),
          if (imc != null) const SizedBox(width: 8),
          if (entry.glucose != null)
            Expanded(child: _MetricCard(
              label: 'Glucosa',
              value: '${entry.glucose!.toStringAsFixed(0)} mg/dL',
              color: entry.glucose! > 126
                  ? context.colors.error
                  : entry.glucose! > 100
                      ? context.nutri.warning
                      : context.nutri.success,
            )),
        ]),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.sub,
    this.color,
  });
  final String label;
  final String value;
  final String? sub;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
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
                style: context.textTheme.titleSmall?.copyWith(
                    color: color ?? context.colors.onSurface,
                    fontWeight: FontWeight.w600)),
            if (sub != null)
              Text(sub!,
                  style: context.textTheme.labelSmall?.copyWith(
                      color: color ?? context.colors.onSurfaceVariant)),
          ],
        ),
      );
}

// ── Chart card wrapper ────────────────────────────────────────────────────────
class _ReferenceLine {
  const _ReferenceLine({
    required this.value,
    required this.label,
    required this.color,
  });
  final double value;
  final String label;
  final Color color;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.icon,
    required this.unit,
    required this.child,
    this.referenceLines = const [],
  });
  final String title;
  final IconData icon;
  final String unit;
  final Widget child;
  final List<_ReferenceLine> referenceLines;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 18, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(title, style: context.textTheme.titleSmall),
                const Spacer(),
                Text(unit,
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant)),
              ]),
              if (referenceLines.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  children: referenceLines.map((r) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 20,
                          height: 2,
                          color: r.color.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text('${r.label} (${r.value.toStringAsFixed(0)})',
                          style: context.textTheme.labelSmall?.copyWith(
                              color: r.color)),
                    ],
                  )).toList(),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(height: 160, child: child),
            ],
          ),
        ),
      );
}

// ── Gráfica de línea genérica ─────────────────────────────────────────────────
class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget({
    required this.spots,
    required this.labels,
    required this.color,
    required this.unit,
    this.minY,
    this.maxY,
  });

  final List<FlSpot> spots;
  final List<String> labels;
  final Color color;
  final String unit;
  final double? minY;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final values = spots.map((s) => s.y).toList();
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final yMin = minY ?? (dataMin - 2).floorToDouble();
    final yMax = maxY ?? (dataMax + 2).ceilToDouble();
    final gridColor = context.colors.onSurface.withOpacity(0.06);
    final textColor = context.colors.onSurfaceVariant;

    return LineChart(LineChartData(
      minY: yMin,
      maxY: yMax,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (yMax - yMin) / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: gridColor, strokeWidth: 0.8),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: (yMax - yMin) / 4,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: TextStyle(fontSize: 10, color: textColor),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
              
              // Con 5 o menos consultas muestra todas, si hay más solo primera y última
              if (labels.length <= 5 || idx == 0 || idx == labels.length - 1) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[idx],
                      style: TextStyle(fontSize: 10, color: textColor)),
                );
              }
              return const SizedBox.shrink();
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
          getTooltipItems: (spots) => spots.map((s) =>
            LineTooltipItem(
              '${s.y.toStringAsFixed(1)} $unit',
              TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 4,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: .07),
          ),
        ),
      ],
    ));
  }
}

// ── Gráfica de IMC con zonas de color ─────────────────────────────────────────
class _ImcChart extends StatelessWidget {
  const _ImcChart({required this.entries, required this.labels});
  final List<ClinicalEntry> entries;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final spots = entries
        .asMap()
        .entries
        .where((e) => e.value.imc != null)
        .map((e) => FlSpot(e.key.toDouble(), e.value.imc!))
        .toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    final textColor = context.colors.onSurfaceVariant;

    return LineChart(LineChartData(
      minY: 15,
      maxY: 40,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (v) {
          // Líneas de referencia en los rangos del IMC
          if (v == 18.5 || v == 25 || v == 30) {
            return FlLine(
              color: context.colors.onSurface.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          }
          return FlLine(
              color: context.colors.onSurface.withOpacity(0.06),
              strokeWidth: 0.8);
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: 5,
            getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                  
                  // Con 5 o menos consultas muestra todas, si hay más solo primera y última
                  if (labels.length <= 5 || idx == 0 || idx == labels.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[idx],
                          style: TextStyle(fontSize: 10, color: textColor)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, _) {
              final idx = v.toInt();
              if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
              if (idx != 0 && idx != labels.length - 1) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(labels[idx],
                    style: TextStyle(fontSize: 10, color: textColor)),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: context.colors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) {
              final imc = spot.y;
              final color = imc < 18.5
                  ? context.colors.error
                  : imc < 25
                      ? context.nutri.success
                      : imc < 30
                          ? context.nutri.warning
                          : context.colors.error;
              return FlDotCirclePainter(
                radius: 5,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: context.colors.primary.withOpacity(0.06),
          ),
        ),
      ],
    ));
  }
}

// ── Tabla comparativa ─────────────────────────────────────────────────────────
class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.entries, required this.labels});
  final List<ClinicalEntry> entries;
  final List<String> labels;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.table_chart_outlined,
                    size: 18, color: context.colors.primary),
                const SizedBox(width: 8),
                Text('Comparativa por consulta',
                    style: context.textTheme.titleSmall),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 48,
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text('Consulta',
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant))),
                    DataColumn(label: Text('Peso',
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant))),
                    DataColumn(label: Text('IMC',
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant))),
                    DataColumn(label: Text('Glucosa',
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant))),
                    DataColumn(label: Text('Trigl.',
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant))),
                  ],
                  rows: entries.asMap().entries.map((e) {
                    final entry = e.value;
                    final imc = entry.imc;
                    final imcColor = imc == null
                        ? null
                        : imc < 18.5 || imc >= 30
                            ? context.colors.error
                            : imc < 25
                                ? context.nutri.success
                                : context.nutri.warning;
                    final glu = entry.glucose;
                    final gluColor = glu == null
                        ? null
                        : glu > 126
                            ? context.colors.error
                            : glu > 100
                                ? context.nutri.warning
                                : context.nutri.success;

                    return DataRow(cells: [
                      DataCell(Text(labels[e.key],
                          style: context.textTheme.bodySmall)),
                      DataCell(Text(
                          entry.weight != null
                              ? '${entry.weight!.toStringAsFixed(1)} kg'
                              : '—',
                          style: context.textTheme.bodySmall)),
                      DataCell(Text(
                          imc != null ? imc.toStringAsFixed(1) : '—',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: imcColor))),
                      DataCell(Text(
                          glu != null
                              ? '${glu.toStringAsFixed(0)} mg/dL'
                              : '—',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: gluColor))),
                      DataCell(Text(
                          entry.triglycerides != null
                              ? '${entry.triglycerides!.toStringAsFixed(0)}'
                              : '—',
                          style: context.textTheme.bodySmall)),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Estados vacíos ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.patientName});
  final String patientName;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 56, color: context.colors.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('Sin consultas completas',
                  style: context.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'El expediente clínico de $patientName aparecerá aquí después de completar la primera consulta.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
}

class _SingleConsultState extends StatelessWidget {
  const _SingleConsultState({required this.entry});
  final ClinicalEntry entry;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCards(entry: entry),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(context.radiusLg),
            ),
            child: Row(children: [
              Icon(Icons.info_outline,
                  size: 18, color: context.colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Las gráficas de evolución aparecerán a partir de la segunda consulta.',
                  style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant),
                ),
              ),
            ]),
          ),
        ],
      );
}
