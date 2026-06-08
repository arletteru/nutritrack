import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/theme.dart';
import 'step_scaffold.dart';

class Step5Recall24hForm extends HookWidget {
  const Step5Recall24hForm({
    super.key,
    required this.onNext,
    required this.isSaving,
    this.initialData,
  });
  final Future<bool> Function(Map<String, dynamic>) onNext;
  final bool isSaving;
  final Map<String, dynamic>? initialData;

  static const _meals = [
    (key: 'breakfast', icon: Icons.wb_sunny_outlined, label: 'Desayuno',
      hint: 'Ej. Café con leche descremada, 2 tostadas integrales con palta.', defaultTime: '08:30 AM'),
    (key: 'morningSnack', icon: Icons.coffee_outlined, label: 'Colación Mañana',
      hint: 'Ej. Una manzana verde', defaultTime: '11:00 AM'),
    (key: 'lunch', icon: Icons.restaurant_outlined, label: 'Almuerzo',
      hint: 'Ej. Pechuga de pollo a la plancha con ensalada mixta.', defaultTime: '01:30 PM'),
    (key: 'afternoonSnack', icon: Icons.free_breakfast_outlined, label: 'Merienda',
      hint: 'Ej. Té verde con 3 galletas de avena.', defaultTime: '05:00 PM'),
    (key: 'dinner', icon: Icons.nightlight_outlined, label: 'Cena',
      hint: 'Ej. Sopa de verduras y un filete de pescado.', defaultTime: '08:00 PM'),
  ];

  Map<String, dynamic> _mealData(Map? d) => (d as Map<String, dynamic>?) ?? {};

  @override
  Widget build(BuildContext context) {
    final meals = useState<Map<String, Map<String, String>>>({
      for (final m in _meals)
        m.key: {
          'description': (_mealData(initialData?[m.key]))['description'] ?? '',
          'time': (_mealData(initialData?[m.key]))['time'] ?? m.defaultTime,
          'place': (_mealData(initialData?[m.key]))['place'] ?? '',
        }
    });

    return StepScaffold(
      title: 'Recordatorio\nde 24 horas',
      subtitle: 'Registre detalladamente la ingesta del paciente del día anterior.',
      isSaving: isSaving,
      isLastStep: false,
      onNext: () => onNext(meals.value),
      children: [
        ..._meals.map((meal) => _MealCard(
          icon: meal.icon,
          label: meal.label,
          descHint: meal.hint,
          descValue: meals.value[meal.key]?['description'] ?? '',
          timeValue: meals.value[meal.key]?['time'] ?? meal.defaultTime,
          placeValue: meals.value[meal.key]?['place'] ?? '',
          onDescChanged: (v) => meals.value = {
            ...meals.value,
            meal.key: {...meals.value[meal.key]!, 'description': v},
          },
          onTimeChanged: (v) => meals.value = {
            ...meals.value,
            meal.key: {...meals.value[meal.key]!, 'time': v},
          },
          onPlaceChanged: (v) => meals.value = {
            ...meals.value,
            meal.key: {...meals.value[meal.key]!, 'place': v},
          },
        )),
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(context.radiusLg),
          ),
          child: Row(
            children: [
              Icon(Icons.summarize_outlined,
                  color: context.colors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen Ingesta Diaria',
                        style: context.textTheme.titleSmall),
                    Text('Análisis preliminar de frecuencia y variedad.',
                        style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${meals.value.values.where((m) => m['description']?.isNotEmpty ?? false).length}/5 COMIDAS',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.icon,
    required this.label,
    required this.descHint,
    required this.descValue,
    required this.timeValue,
    required this.placeValue,
    required this.onDescChanged,
    required this.onTimeChanged,
    required this.onPlaceChanged,
  });

  final IconData icon;
  final String label;
  final String descHint;
  final String descValue;
  final String timeValue;
  final String placeValue;
  final ValueChanged<String> onDescChanged;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onPlaceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(label, style: context.textTheme.headlineSmall),
          ]),
          const SizedBox(height: 12),
          ConsultField(
            label: 'Descripción',
            hint: descHint,
            initialValue: descValue,
            maxLines: 2,
            onChanged: onDescChanged,
          ),
          Row(children: [
            Expanded(
              child: ConsultField(
                label: 'Hora',
                initialValue: timeValue,
                onChanged: onTimeChanged,
                keyboardType: TextInputType.datetime,
                suffix: const Icon(Icons.access_time_outlined, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ConsultField(
                label: 'Lugar / Contexto',
                initialValue: placeValue,
                onChanged: onPlaceChanged,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
