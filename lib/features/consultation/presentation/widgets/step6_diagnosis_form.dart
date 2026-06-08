import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/theme.dart';
import 'step_scaffold.dart';

class Step6DiagnosisForm extends HookWidget {
  const Step6DiagnosisForm({
    super.key,
    required this.onFinish,
    required this.isSaving,
    this.initialData,
  });
  final Future<void> Function(Map<String, dynamic>) onFinish;
  final bool isSaving;
  final Map<String, dynamic>? initialData;

  @override
  Widget build(BuildContext context) {
    final findingsACtrl = useTextEditingController(text: initialData?['findingsA'] ?? '');
    final findingsBCtrl = useTextEditingController(text: initialData?['findingsB'] ?? '');
    final findingsCCtrl = useTextEditingController(text: initialData?['findingsC'] ?? '');
    final findingsDCtrl = useTextEditingController(text: initialData?['findingsD'] ?? '');
    final problemsCtrl = useTextEditingController(text: initialData?['pesNutritionProblem'] ?? '');
    final etiologyCtrl = useTextEditingController(text: initialData?['pesEtiology'] ?? '');
    final signsCtrl = useTextEditingController(text: initialData?['pesSigns'] ?? '');
    final treatmentCtrl = useTextEditingController(text: initialData?['treatmentObjectives'] ?? '');
    final recoCtrl = useTextEditingController(text: '');

    final detectedProblems = useState<List<String>>(
        List<String>.from(initialData?['detectedProblems'] ?? []));
    final recommendations = useState<List<String>>(
        List<String>.from(initialData?['generalRecommendations'] ?? []));
    final macros = useState<List<Map<String, String>>>(
      (initialData?['macroModifications'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ??
      [
        {'nutrient': 'Proteínas', 'modification': '+20%', 'description': 'Incrementa a 1.5g/kg'},
        {'nutrient': 'Carbohidratos', 'modification': '-15%', 'description': 'Control de índice glucémico'},
        {'nutrient': 'Grasas', 'modification': 'Mantener', 'description': 'Priorizar ácidos grasos Omega-3'},
      ],
    );
    final suggestedProblems = [
      'Ingesta excesiva de energía',
      'Ingesta insuficiente de proteína',
      'Desequilibrio nutricional',
      'Sedentarismo reportado',
      'Ingesta deficiente de hierro',
      'Ingesta excesiva de sodio',
    ];

    return StepScaffold(
      title: 'Análisis y\nDiagnóstico\nNutricional',
      subtitle: 'Integre los hallazgos clínicos usando la metodología PES.',
      isSaving: isSaving,
      isLastStep: true,
      nextLabel: 'Finalizar y Guardar',
      nextIcon: Icons.save_outlined,
      onNext: () => onFinish({
        'findingsA': findingsACtrl.text,
        'findingsB': findingsBCtrl.text,
        'findingsC': findingsCCtrl.text,
        'findingsD': findingsDCtrl.text,
        'detectedProblems': detectedProblems.value,
        'pesNutritionProblem': problemsCtrl.text,
        'pesEtiology': etiologyCtrl.text,
        'pesSigns': signsCtrl.text,
        'treatmentObjectives': treatmentCtrl.text,
        'generalRecommendations': recommendations.value,
        'macroModifications': macros.value,
      }),
      children: [
        // 1. Resumen de hallazgos
        FormSection(
          title: '1. Resumen de Hallazgos',
          icon: Icons.summarize_outlined,
          children: [
            ConsultField(label: 'A. Antropometría',
                controller: findingsACtrl, maxLines: 3,
                hint: 'Ej. IMC 28.5 kg/m² (Sobrepeso), % Grasa Corporal elevado...'),
            ConsultField(label: 'B. Bioquímicos',
                controller: findingsBCtrl, maxLines: 3,
                hint: 'Ej. Glucosa basal 105 mg/dl...'),
            ConsultField(label: 'C. Clínicos',
                controller: findingsCCtrl, maxLines: 3,
                hint: 'Ej. Fatiga, xerosis cutánea...'),
            ConsultField(label: 'D. Dietéticos',
                controller: findingsDCtrl, maxLines: 3,
                hint: 'Ej. Consumo excesivo de azúcares simples, bajo aporte de fibra...'),
          ],
        ),

        // Problemas detectados
        FormSection(
          title: 'Problemas Detectados',
          icon: Icons.warning_amber_outlined,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...detectedProblems.value.map((p) => InputChip(
                  label: Text(p),
                  backgroundColor: context.colors.errorContainer,
                  labelStyle: TextStyle(color: context.colors.error),
                  onDeleted: () => detectedProblems.value =
                      detectedProblems.value.where((e) => e != p).toList(),
                )),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggestedProblems
                  .where((p) => !detectedProblems.value.contains(p))
                  .map((p) => ActionChip(
                    label: Text('+ $p', style: context.textTheme.labelSmall),
                    onPressed: () => detectedProblems.value =
                        [...detectedProblems.value, p],
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ))
                  .toList(),
            ),
          ],
        ),

        // 2. Diagnóstico PES
        FormSection(
          title: '2. Diagnóstico Nutricional (PES)',
          icon: Icons.medical_information_outlined,
          children: [
            _PesField(
              number: '①',
              label: 'Problema',
              hint: 'Relacionado con...',
              controller: problemsCtrl,
            ),
            _PesField(
              number: '②',
              label: 'Etiología',
              hint: 'Evidenciado por...',
              controller: etiologyCtrl,
            ),
            _PesField(
              number: '③',
              label: 'Signos y Síntomas',
              hint: 'Resultados específicos...',
              controller: signsCtrl,
            ),
          ],
        ),

        // 3. Metas y tratamiento
        FormSection(
          title: '3. Metas y Tratamiento',
          icon: Icons.flag_outlined,
          children: [
            ConsultField(
              label: 'Objetivos del tratamiento',
              controller: treatmentCtrl,
              maxLines: 3,
              hint: 'Ej. Reducción del 5% de grasa corporal en 3 meses...',
            ),
            // Recomendaciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recomendaciones Generales',
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        letterSpacing: 0.8)),
                const SizedBox(height: 8),
                ...recommendations.value.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: context.textTheme.bodyMedium)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => recommendations.value =
                          recommendations.value.where((e) => e != r).toList(),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ]),
                )),
                Row(children: [
                  Expanded(child: TextField(
                    controller: recoCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Agregar recomendación...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: context.colors.primary),
                        onPressed: () {
                          if (recoCtrl.text.trim().isNotEmpty) {
                            recommendations.value = [...recommendations.value, recoCtrl.text.trim()];
                            recoCtrl.clear();
                          }
                        },
                      ),
                    ),
                  )),
                ]),
              ],
            ),
          ],
        ),

        // 4. Modificaciones de ingesta
        FormSection(
          title: '4. Modificaciones de Ingesta',
          icon: Icons.tune_outlined,
          children: [
            // Lista de macros editables
            ...macros.value.map((m) => _MacroRow(
              nutrient: m['nutrient'] ?? '',
              modification: m['modification'] ?? '',
              description: m['description'] ?? '',
              onEdit: () async {
                final result = await _showMacroDialog(
                  context,
                  macro: m,
                );
                if (result != null) {
                  final idx = macros.value.indexOf(m);
                  final updated = [...macros.value];
                  updated[idx] = result;
                  macros.value = updated;
                }
              },
              onDelete: () {
                macros.value = macros.value.where((e) => e != m).toList();
              },
            )),

            const SizedBox(height: 8),

            // Botón ajustar — ahora abre el diálogo para agregar nuevo
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      final result = await _showMacroDialog(context, macro: null);
                      if (result != null) {
                        macros.value = [...macros.value, result];
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Agregar macronutriente'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  Future<Map<String, String>?> _showMacroDialog(
      BuildContext context, {
      required Map<String, String>? macro, // null = nuevo, Map = editar
    }) {
      return showDialog<Map<String, String>>(
        context: context,
        builder: (ctx) => _MacroDialog(initialMacro: macro),
      );
    }
}

class _PesField extends StatelessWidget {
  const _PesField({
    required this.number,
    required this.label,
    required this.hint,
    required this.controller,
  });
  final String number;
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(context.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(number,
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ConsultField(
              label: label,
              controller: controller,
              hint: hint,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroDialog extends HookWidget {
  const _MacroDialog({required this.initialMacro});
  final Map<String, String>? initialMacro;

  static const _nutrients = [
    'Proteínas',
    'Carbohidratos',
    'Grasas',
    'Fibra',
    'Sodio',
    'Azúcares',
    'Otro',
  ];

  static const _modificationTypes = [
    '+5%', '+10%', '+15%', '+20%', '+25%', '+30%',
    '-5%', '-10%', '-15%', '-20%', '-25%', '-30%',
    'Mantener',
    'Restricción total',
    'Personalizado',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedNutrient = useState<String>(
      initialMacro?['nutrient'] ?? _nutrients.first,
    );
    final selectedMod = useState<String>(
      initialMacro?['modification'] ?? _modificationTypes.first,
    );
    final customModCtrl = useTextEditingController(
      text: selectedMod.value == 'Personalizado'
          ? (initialMacro?['modification'] ?? '')
          : '',
    );
    final descCtrl = useTextEditingController(
      text: initialMacro?['description'] ?? '',
    );
    final isCustom = useState(
      !_modificationTypes.contains(initialMacro?['modification']) &&
          initialMacro != null,
    );

    return AlertDialog(
      title: Text(
        initialMacro == null ? 'Agregar macronutriente' : 'Editar macronutriente',
        style: context.textTheme.headlineSmall,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nutriente ──────────────────────────────────────────────────
            Text(
              'NUTRIENTE',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(context.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedNutrient.value,
                  isExpanded: true,
                  items: _nutrients
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) selectedNutrient.value = v;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Modificación ───────────────────────────────────────────────
            Text(
              'MODIFICACIÓN',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(context.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: isCustom.value ? 'Personalizado' : selectedMod.value,
                  isExpanded: true,
                  items: _modificationTypes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    if (v == 'Personalizado') {
                      isCustom.value = true;
                    } else {
                      isCustom.value = false;
                      selectedMod.value = v;
                    }
                  },
                ),
              ),
            ),

            // Campo personalizado
            if (isCustom.value) ...[
              const SizedBox(height: 10),
              TextField(
                controller: customModCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej. +12%, reducir a 100g/día...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Descripción ────────────────────────────────────────────────
            Text(
              'DESCRIPCIÓN / INDICACIÓN',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ej. Priorizar proteína de alto valor biológico',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.radiusMd),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.colors.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final mod = isCustom.value
                ? customModCtrl.text.trim()
                : selectedMod.value;
            if (mod.isEmpty) return;

            Navigator.pop(context, {
              'nutrient': selectedNutrient.value,
              'modification': mod,
              'description': descCtrl.text.trim(),
            });
          },
          child: Text(initialMacro == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.nutrient,
    required this.modification,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  final String nutrient;
  final String modification;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPositive = modification.startsWith('+');
    final isNeutral = modification == 'Mantener';
    final color = isNeutral
        ? context.colors.onSurfaceVariant
        : isPositive
            ? context.nutri.success
            : context.colors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nutrient, style: context.textTheme.titleSmall),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              modification,
              style: context.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
          // Botones de acción
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: context.colors.onSurfaceVariant),
            onPressed: onEdit,
            tooltip: 'Editar',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: context.colors.error),
            onPressed: onDelete,
            tooltip: 'Eliminar',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(left: 4),
          ),
        ],
      ),
    );
  }
}
