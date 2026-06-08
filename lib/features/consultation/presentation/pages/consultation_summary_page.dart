// features/consultation/presentation/pages/consultation_summary_page.dart
//
// CAPA: Presentation
// Quién la usa: AMBOS roles.
//   - Nutriólogo: llega desde ConsultationsListPage o PatientDetailPage
//   - Paciente: llega desde HomePatientPage → "Mi última consulta"
//
// Lee los 6 pasos desde Firestore y los muestra en modo lectura.
// El nutriólogo ve además un botón para editar/continuar si está en borrador.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutritrack/features/consultation/presentation/widgets/generate_plan_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/consultation_entity.dart';
import '../providers/consultation_providers.dart';

part 'consultation_summary_page.g.dart';

// ── Provider: carga los 6 pasos en paralelo ────────────────────────────────
@riverpod
Future<Map<int, Map<String, dynamic>?>> loadAllSteps(
  Ref ref,
  String consultationId,
) async {
  final repo = ref.watch(consultationRepositoryProvider);
  final results = await Future.wait(
    List.generate(6, (i) => repo.getStep(consultationId, i + 1)),
  );
  return {
    for (var i = 0; i < results.length; i++) i + 1: results[i],
  };
}

// ── Page ──────────────────────────────────────────────────────────────────────
class ConsultationSummaryPage extends ConsumerWidget {
  const ConsultationSummaryPage({
    super.key,
    required this.consultationId,
    required this.isNutriologist,
    this.consultationData,
  });

  final String consultationId;
  final bool isNutriologist;
  // Datos básicos del documento padre (tipo, status, createdAt)
  final Map<String, dynamic>? consultationData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync =
        ref.watch(loadAllStepsProvider(consultationId));

    final status = consultationData?['status'] as String?;
    final isDraft = status == ConsultationStatus.draft.name;
    final type = consultationData?['type'] as String? ?? 'first';

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == 'first' ? 'Primera consulta' : 'Seguimiento',
              style: context.textTheme.headlineMedium,
            ),
            if (consultationData?['createdAt'] != null)
              Text(
                _formatDate(consultationData!['createdAt']),
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          // ── Generar plan (solo nutriólogo, consulta completa) ─────────────────
          if (isNutriologist && !isDraft)
            stepsAsync.whenOrNull(
              data: (steps) {
                final step6 = steps[6];
                if (step6 == null) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.auto_awesome_outlined),
                  tooltip: 'Generar plan nutricional',
                  onPressed: () async {
                    final patientId =
                        consultationData?['patientId'] as String? ?? '';
                    final patientUid =
                        consultationData?['patientUid'] as String? ?? '';
                    final nutriologistId =
                        consultationData?['nutriologistId'] as String? ?? '';

                    if (patientUid.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                          'El paciente aún no tiene cuenta. '
                          'Sincroniza primero desde el perfil del paciente.',
                        ),
                        backgroundColor: context.nutri.warning,
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }

                    await GeneratePlanDialog.show(
                      context,
                      patientId: patientId,
                      patientUid: patientUid,
                      nutriologistId: nutriologistId,
                      consultationId: consultationId,
                      step6Data: step6,
                    );
                  },
                );
              },
            ) ?? const SizedBox.shrink(),

          // ── Continuar borrador (solo nutriólogo, draft) ───────────────────────
          if (isNutriologist && isDraft)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Continuar'),
                onPressed: () => context.push(
                  '/consultation/new?consultationId=$consultationId',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),

          const SizedBox(width: 4),
        ],
      ),

      body: stepsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: TextStyle(color: context.colors.error)),
        ),
        data: (steps) => _SummaryBody(
          steps: steps,
          isNutriologist: isNutriologist,
        ),
      ),
    );
  }

  String _formatDate(dynamic raw) {
    try {
      final dt = raw is String
          ? DateTime.parse(raw)
          : (raw as dynamic).toDate() as DateTime;
      return DateFormat('d MMMM yyyy', 'es_MX').format(dt);
    } catch (_) {
      return '';
    }
  }
}

// ── Body con todos los pasos ──────────────────────────────────────────────────
class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.steps,
    required this.isNutriologist,
  });

  final Map<int, Map<String, dynamic>?> steps;
  final bool isNutriologist;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (steps[1] != null) _Step1Section(data: steps[1]!),
        if (steps[2] != null) _Step2Section(data: steps[2]!),
        if (steps[3] != null && isNutriologist)
          _Step3Section(data: steps[3]!),
        if (steps[4] != null) _Step4Section(data: steps[4]!),
        if (steps[5] != null) _Step5Section(data: steps[5]!),
        if (steps[6] != null) _Step6Section(data: steps[6]!),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Sección base ──────────────────────────────────────────────────────────────
class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.icon,
    required this.children,
    this.stepNumber,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final int? stepNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Icon(icon, size: 20, color: context.colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: context.textTheme.headlineSmall),
              ),
              if (stepNumber != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Paso $stepNumber',
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.primary),
                  ),
                ),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de lectura ──────────────────────────────────────────────────────────
class _ReadField extends StatelessWidget {
  const _ReadField({required this.label, required this.value, this.suffix});
  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suffix != null ? '$value $suffix' : value,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ── Paso 1: Metadatos ─────────────────────────────────────────────────────────
class _Step1Section extends StatelessWidget {
  const _Step1Section({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return _SummarySection(
      title: 'Información general',
      icon: Icons.info_outline,
      stepNumber: 1,
      children: [
        _ReadField(label: 'Fecha', value: data['consultationDate'] ?? ''),
        _ReadField(label: 'Hora', value: data['consultationTime'] ?? ''),
        _ReadField(label: 'Expediente', value: data['expediente'] ?? ''),
        _ReadField(label: 'Nombre completo', value: data['fullName'] ?? ''),
        _ReadField(label: 'Edad', value: '${data['age'] ?? ''}', suffix: 'años'),
        _ReadField(label: 'Tipo de consulta', value: data['consultType'] ?? ''),
        if (data['isPregnant'] == true)
          _InfoChip(label: 'Embarazo', icon: Icons.pregnant_woman_outlined),
        if (data['isMinor'] == true)
          _InfoChip(label: 'Menor de 18', icon: Icons.child_care_outlined),
        _ReadField(label: 'Motivo', value: data['referralReason'] ?? ''),
        _ReadField(label: 'Ocupación', value: data['occupation'] ?? ''),
        _ReadField(label: 'Escolaridad', value: data['educationLevel'] ?? ''),
        _ReadField(label: 'Red de apoyo', value: data['supportNetwork'] ?? ''),
      ],
    );
  }
}

// ── Paso 2: Antropometría ─────────────────────────────────────────────────────
class _Step2Section extends StatelessWidget {
  const _Step2Section({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final imc = (data['imc'] as num?)?.toDouble();
    String imcLabel = '';
    Color imcColor = context.colors.primary;
    if (imc != null) {
      if (imc < 18.5) { imcLabel = 'Bajo peso'; imcColor = context.colors.error; }
      else if (imc < 25) { imcLabel = 'Normopeso'; imcColor = context.nutri.success; }
      else if (imc < 30) { imcLabel = 'Sobrepeso'; imcColor = context.nutri.warning; }
      else { imcLabel = 'Obesidad'; imcColor = context.colors.error; }
    }

    return _SummarySection(
      title: 'Antropometría',
      icon: Icons.monitor_weight_outlined,
      stepNumber: 2,
      children: [
        _ReadField(label: 'Talla', value: '${data['height'] ?? ''}', suffix: 'cm'),
        _ReadField(label: 'Peso actual', value: '${data['currentWeight'] ?? ''}', suffix: 'kg'),
        _ReadField(label: 'Peso habitual', value: '${data['usualWeight'] ?? ''}', suffix: 'kg'),
        _ReadField(label: 'Peso pregestacional', value: '${data['pregestationalWeight'] ?? ''}', suffix: 'kg'),
        _ReadField(label: 'Semanas de gestación', value: '${data['gestationalWeeks'] ?? ''}', suffix: 'SDG'),
        if (imc != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('IMC', style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant, letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(imc.toStringAsFixed(1),
                    style: context.textTheme.headlineLarge
                        ?.copyWith(color: context.colors.onSurface)),
              ]),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: imcColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(imcLabel,
                    style: context.textTheme.labelMedium
                        ?.copyWith(color: imcColor)),
              ),
            ]),
          ),
        ],
        _ReadField(label: 'Cintura', value: '${data['waist'] ?? ''}', suffix: 'cm'),
        _ReadField(label: 'Cadera', value: '${data['hip'] ?? ''}', suffix: 'cm'),
      ],
    );
  }
}

// ── Paso 3: Bioquímicos (solo nutriólogo) ─────────────────────────────────────
class _Step3Section extends StatelessWidget {
  const _Step3Section({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return _SummarySection(
      title: 'Datos bioquímicos',
      icon: Icons.biotech_outlined,
      stepNumber: 3,
      children: [
        _ReadField(label: 'Glucosa basal', value: '${data['glucose'] ?? ''}', suffix: 'mg/dL'),
        _ReadField(label: 'HbA1c', value: '${data['hba1c'] ?? ''}', suffix: '%'),
        _ReadField(label: 'Colesterol total', value: '${data['totalCholesterol'] ?? ''}', suffix: 'mg/dL'),
        _ReadField(label: 'HDL', value: '${data['hdl'] ?? ''}', suffix: 'mg/dL'),
        _ReadField(label: 'LDL', value: '${data['ldl'] ?? ''}', suffix: 'mg/dL'),
        _ReadField(label: 'Triglicéridos', value: '${data['triglycerides'] ?? ''}', suffix: 'mg/dL'),
        _ReadField(label: 'Hemoglobina', value: '${data['hemoglobin'] ?? ''}', suffix: 'g/dL'),
        _ReadField(label: 'Observaciones', value: data['observations'] ?? ''),
      ],
    );
  }
}

// ── Paso 4: Dietética ─────────────────────────────────────────────────────────
class _Step4Section extends StatelessWidget {
  const _Step4Section({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final preferred = List<String>.from(data['preferredFoods'] ?? []);
    final allergies = List<String>.from(data['allergiesIntolerances'] ?? []);

    return _SummarySection(
      title: 'Hábitos dietéticos',
      icon: Icons.restaurant_outlined,
      stepNumber: 4,
      children: [
        _ReadField(label: 'Agua diaria', value: '${data['waterLiters'] ?? ''}', suffix: 'L'),
        _ReadField(label: 'Comidas al día', value: '${data['mealsPerDay'] ?? ''}'),
        _ReadField(label: 'Nivel de apetito', value: data['appetiteLevel'] ?? ''),
        _ReadField(label: 'Quién prepara la comida', value: data['whoPreparesFood'] ?? ''),
        if (preferred.isNotEmpty) ...[
          Text('ALIMENTOS PREFERIDOS',
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: preferred
                .map((f) => Chip(
                      label: Text(f, style: context.textTheme.labelSmall),
                      backgroundColor: context.colors.primaryContainer,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (allergies.isNotEmpty) ...[
          Text('ALERGIAS / INTOLERANCIAS',
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allergies
                .map((a) => Chip(
                      label: Text(a, style: context.textTheme.labelSmall),
                      backgroundColor: context.colors.errorContainer,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ── Paso 5: Recordatorio 24h ──────────────────────────────────────────────────
class _Step5Section extends StatelessWidget {
  const _Step5Section({required this.data});
  final Map<String, dynamic> data;

  static const _mealKeys = [
    ('breakfast', 'Desayuno', Icons.wb_sunny_outlined),
    ('morningSnack', 'Colación mañana', Icons.coffee_outlined),
    ('lunch', 'Almuerzo', Icons.restaurant_outlined),
    ('afternoonSnack', 'Merienda', Icons.free_breakfast_outlined),
    ('dinner', 'Cena', Icons.nightlight_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return _SummarySection(
      title: 'Recordatorio 24 horas',
      icon: Icons.schedule_outlined,
      stepNumber: 5,
      children: [
        ..._mealKeys.map((m) {
          final meal = data[m.$1] as Map?;
          if (meal == null) return const SizedBox.shrink();
          final desc = meal['description'] as String? ?? '';
          if (desc.isEmpty) return const SizedBox.shrink();
          return _MealReadTile(
            icon: m.$3,
            label: m.$2,
            description: desc,
            time: meal['time'] as String? ?? '',
            place: meal['place'] as String? ?? '',
          );
        }),
      ],
    );
  }
}

class _MealReadTile extends StatelessWidget {
  const _MealReadTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.time,
    required this.place,
  });
  final IconData icon;
  final String label;
  final String description;
  final String time;
  final String place;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(description, style: context.textTheme.bodyMedium),
                if (time.isNotEmpty || place.isNotEmpty)
                  Text(
                    [if (time.isNotEmpty) time, if (place.isNotEmpty) place]
                        .join(' · '),
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
}

// ── Paso 6: Diagnóstico PES ───────────────────────────────────────────────────
class _Step6Section extends StatelessWidget {
  const _Step6Section({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final problems = List<String>.from(data['detectedProblems'] ?? []);
    final recommendations =
        List<String>.from(data['generalRecommendations'] ?? []);
    final macros =
        List<dynamic>.from(data['macroModifications'] ?? []);

    return _SummarySection(
      title: 'Diagnóstico y plan',
      icon: Icons.medical_information_outlined,
      stepNumber: 6,
      children: [
        // Hallazgos
        _ReadField(label: 'A. Antropometría', value: data['findingsA'] ?? ''),
        _ReadField(label: 'B. Bioquímicos', value: data['findingsB'] ?? ''),
        _ReadField(label: 'C. Clínicos', value: data['findingsC'] ?? ''),
        _ReadField(label: 'D. Dietéticos', value: data['findingsD'] ?? ''),

        // Problemas
        if (problems.isNotEmpty) ...[
          Text('PROBLEMAS DETECTADOS',
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: problems
                .map((p) => Chip(
                      label: Text(p, style: context.textTheme.labelSmall),
                      backgroundColor: context.colors.errorContainer,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // PES
        _PesReadRow(number: '①', label: 'Problema',
            value: data['pesNutritionProblem'] ?? ''),
        _PesReadRow(number: '②', label: 'Etiología',
            value: data['pesEtiology'] ?? ''),
        _PesReadRow(number: '③', label: 'Signos y síntomas',
            value: data['pesSigns'] ?? ''),

        _ReadField(
            label: 'Objetivos del tratamiento',
            value: data['treatmentObjectives'] ?? ''),

        // Recomendaciones
        if (recommendations.isNotEmpty) ...[
          Text('RECOMENDACIONES',
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ...recommendations.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Icon(Icons.check_circle_outline,
                  size: 16, color: context.colors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(r, style: context.textTheme.bodyMedium)),
            ]),
          )),
          const SizedBox(height: 12),
        ],

        // Macros
        if (macros.isNotEmpty) ...[
          Text('MODIFICACIONES DE INGESTA',
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ...macros.map((m) {
            final mod = m['modification'] as String? ?? '';
            final isPos = mod.startsWith('+');
            final isNeutral = mod == 'Mantener';
            final color = isNeutral
                ? context.colors.onSurfaceVariant
                : isPos ? context.nutri.success : context.colors.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text(m['nutrient'] as String? ?? '',
                    style: context.textTheme.titleSmall)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(mod,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: color)),
                ),
              ]),
            );
          }),
        ],
      ],
    );
  }
}

class _PesReadRow extends StatelessWidget {
  const _PesReadRow(
      {required this.number, required this.label, required this.value});
  final String number;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colors.primary)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(value, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: context.colors.primary),
        const SizedBox(width: 6),
        Text(label, style: context.textTheme.bodyMedium
            ?.copyWith(color: context.colors.primary)),
      ]),
    );
  }
}
