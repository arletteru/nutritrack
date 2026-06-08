import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/theme.dart';
import 'step_scaffold.dart';

class Step4DietaryForm extends HookWidget {
  const Step4DietaryForm({
    super.key,
    required this.onNext,
    required this.isSaving,
    this.initialData,
  });
  final Future<bool> Function(Map<String, dynamic>) onNext;
  final bool isSaving;
  final Map<String, dynamic>? initialData;

  static const _foodGroups = [
    'Bebidas azucaradas',
    'Grasas y aceites',
    'Cereales e integrales',
    'Frutas y verduras',
    'Proteínas animales',
    'Lácteos',
    'Leguminosas',
    'Comida rápida',
  ];

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Frecuencia (días/semana)
    final freq = useState<Map<String, int>>(
      Map.fromEntries(_foodGroups.map((g) =>
          MapEntry(g, (initialData?['foodFrequency'] as Map?)?[g] ?? 0))));

    final waterLiters = useState<double>(
        (initialData?['waterLiters'] as num?)?.toDouble() ?? 1.5);
    final coffeeCtrl = useTextEditingController(
        text: initialData?['coffeeTea']?.toString() ?? '');
    final softCtrl = useTextEditingController(
        text: initialData?['softDrinks']?.toString() ?? '');
    final mealsCtrl = useTextEditingController(
        text: initialData?['mealsPerDay']?.toString() ?? '3');
    final prepTimeCtrl = useTextEditingController(
        text: initialData?['mealPrepTime']?.toString() ?? '30');
    final whoPreparesCtrl = useState<String>(
        initialData?['whoPreparesFood'] ?? 'Paciente mismo');
    final appetiteCtrl = useState<String>(
        initialData?['appetiteLevel'] ?? 'Normal');

    final preferredFoods = useState<List<String>>(
        List<String>.from(initialData?['preferredFoods'] ?? []));
    final allergies = useState<List<String>>(
        List<String>.from(initialData?['allergiesIntolerances'] ?? []));
    final newFoodCtrl = useTextEditingController();
    final newAllergyCtrl = useTextEditingController();

    return Form(
      key: formKey,
      child: StepScaffold(
        title: 'Evaluación\nDietética',
        subtitle: 'Análisis detallado de hábitos de consumo y preferencias.',
        isSaving: isSaving,
        onNext: () => onNext({
          'foodFrequency': freq.value,
          'waterLiters': waterLiters.value,
          'coffeeTea': double.tryParse(coffeeCtrl.text),
          'softDrinks': double.tryParse(softCtrl.text),
          'whoPreparesFood': whoPreparesCtrl.value,
          'mealsPerDay': int.tryParse(mealsCtrl.text) ?? 3,
          'mealPrepTime': int.tryParse(prepTimeCtrl.text) ?? 30,
          'appetiteLevel': appetiteCtrl.value,
          'preferredFoods': preferredFoods.value,
          'allergiesIntolerances': allergies.value,
        }),
        children: [
          // Frecuencia de consumo
          FormSection(
            title: 'Frecuencia de Consumo',
            icon: Icons.bar_chart_outlined,
            subtitle: 'Días por semana (0–7)',
            children: _foodGroups.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(group,
                          style: context.textTheme.bodyMedium),
                    ),
                    const SizedBox(width: 12),
                    _FrequencyPicker(
                      value: freq.value[group] ?? 0,
                      onChanged: (v) {
                        freq.value = {...freq.value, group: v};
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Hidratación
          FormSection(
            title: 'Hidratación y Líquidos',
            icon: Icons.water_drop_outlined,
            children: [
              _WaterPicker(
                value: waterLiters.value,
                onChanged: (v) => waterLiters.value = v,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ConsultField(
                  label: 'Café o Té (tazas/día)',
                  controller: coffeeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: 'Ej. 2 tazas/día',
                )),
                const SizedBox(width: 12),
                Expanded(child: ConsultField(
                  label: 'Refrescos/Jugos (L/día)',
                  controller: softCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: 'Ej. 1 lata diaria',
                )),
              ]),
            ],
          ),

          // Logística
          FormSection(
            title: 'Logística y Preferencias',
            icon: Icons.restaurant_outlined,
            children: [
              // Alimentos preferidos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alimentos que le gustan',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...preferredFoods.value.map((f) => InputChip(
                        label: Text(f),
                        onDeleted: () => preferredFoods.value =
                            preferredFoods.value.where((e) => e != f).toList(),
                      )),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: newFoodCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                              hintText: 'Agregar alimento...',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              preferredFoods.value = [...preferredFoods.value, v.trim()];
                              newFoodCtrl.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              // Alergias
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alergias o intolerancias',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...allergies.value.map((a) => InputChip(
                        label: Text(a),
                        backgroundColor:
                            context.colors.errorContainer,
                        onDeleted: () => allergies.value =
                            allergies.value.where((e) => e != a).toList(),
                      )),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: newAllergyCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                              hintText: '+ Añadir',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              allergies.value = [...allergies.value, v.trim()];
                              newAllergyCtrl.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              // Quién prepara, comidas y apetito
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Quién prepara la comida?',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(context.radiusMd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: whoPreparesCtrl.value,
                        isExpanded: true,
                        items: ['Paciente mismo', 'Familiar', 'Servicio de comida', 'Restaurante']
                            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) { if (v != null) whoPreparesCtrl.value = v; },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              Row(children: [
                Expanded(child: ConsultField(
                  label: '# Comidas al día',
                  controller: mealsCtrl,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: ConsultField(
                  label: 'Tiempo p/comer (min)',
                  controller: prepTimeCtrl,
                  keyboardType: TextInputType.number,
                )),
              ]),
              // Nivel de apetito
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nivel de Apetito',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Bajo', label: Text('Bajo')),
                      ButtonSegment(value: 'Normal', label: Text('Normal')),
                      ButtonSegment(value: 'Alto', label: Text('Alto')),
                    ],
                    selected: {appetiteCtrl.value},
                    onSelectionChanged: (s) => appetiteCtrl.value = s.first,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: context.colors.primaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          style: IconButton.styleFrom(
              padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
        ),
        SizedBox(
          width: 40,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: value < 7 ? () => onChanged(value + 1) : null,
          style: IconButton.styleFrom(
              padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
        ),
        Text('días', style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant)),
      ],
    );
  }
}

class _WaterPicker extends StatelessWidget {
  const _WaterPicker({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(context.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop, color: context.colors.primary, size: 28),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 0.5 ? () => onChanged((value - 0.5)) : null,
          ),
          Column(
            children: [
              Text(value.toStringAsFixed(1),
                  style: context.textTheme.headlineLarge?.copyWith(
                      color: context.colors.primary)),
              Text('Litros por día',
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(value + 0.5),
          ),
        ],
      ),
    );
  }
}
