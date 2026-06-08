import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/theme.dart';
import 'step_scaffold.dart';

class Step2AnthropometryForm extends HookWidget {
  const Step2AnthropometryForm({
    super.key,
    required this.onNext,
    required this.isSaving,
    this.initialData,
  });

  final Future<bool> Function(Map<String, dynamic>) onNext;
  final bool isSaving;
  final Map<String, dynamic>? initialData;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final heightCtrl = useTextEditingController(
        text: initialData?['height']?.toString() ?? '');
    final currentWeightCtrl = useTextEditingController(
        text: initialData?['currentWeight']?.toString() ?? '');
    final usualWeightCtrl = useTextEditingController(
        text: initialData?['usualWeight']?.toString() ?? '');
    final pregestCtrl = useTextEditingController(
        text: initialData?['pregestationalWeight']?.toString() ?? '');
    final gestWeeksCtrl = useTextEditingController(
        text: initialData?['gestationalWeeks']?.toString() ?? '');
    final waistCtrl = useTextEditingController(
        text: initialData?['waist']?.toString() ?? '');
    final hipCtrl = useTextEditingController(
        text: initialData?['hip']?.toString() ?? '');
    final armCtrl = useTextEditingController(
        text: initialData?['armCircumference']?.toString() ?? '');
    final tricepsCtrl = useTextEditingController(
        text: initialData?['tricepsFold']?.toString() ?? '');

    // IMC calculado reactivamente
    final imcValue = useState<double?>(null);

    void recalcImc() {
      final h = double.tryParse(heightCtrl.text);
      final w = double.tryParse(currentWeightCtrl.text);
      if (h != null && w != null && h > 0) {
        imcValue.value = w / ((h / 100) * (h / 100));
      } else {
        imcValue.value = null;
      }
    }

    useEffect(() {
      heightCtrl.addListener(recalcImc);
      currentWeightCtrl.addListener(recalcImc);
      return () {
        heightCtrl.removeListener(recalcImc);
        currentWeightCtrl.removeListener(recalcImc);
      };
    }, []);

    String imcCategory(double imc) {
      if (imc < 18.5) return 'Bajo peso';
      if (imc < 25) return 'Normopeso';
      if (imc < 30) return 'Sobrepeso';
      return 'Obesidad';
    }

    Color imcColor(double imc, BuildContext ctx) {
      if (imc < 18.5) return ctx.colors.error;
      if (imc < 25) return ctx.nutri.success;
      if (imc < 30) return ctx.nutri.warning;
      return ctx.colors.error;
    }

    return Form(
      key: formKey,
      child: StepScaffold(
        title: 'Antropometría\nGestacional',
        isSaving: isSaving,
        onNext: () {
          if (formKey.currentState?.validate() ?? false) {
            onNext({
              'height': double.tryParse(heightCtrl.text),
              'currentWeight': double.tryParse(currentWeightCtrl.text),
              'usualWeight': double.tryParse(usualWeightCtrl.text),
              'pregestationalWeight': double.tryParse(pregestCtrl.text),
              'gestationalWeeks': int.tryParse(gestWeeksCtrl.text),
              'waist': double.tryParse(waistCtrl.text),
              'hip': double.tryParse(hipCtrl.text),
              'armCircumference': double.tryParse(armCtrl.text),
              'tricepsFold': double.tryParse(tricepsCtrl.text),
              'imc': imcValue.value,
            });
          }
        },
        children: [
          // Perfil básico
          FormSection(
            title: 'Perfil Básico',
            icon: Icons.person_outline,
            children: [
              ConsultField(
                label: 'Talla (cm)',
                controller: heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              ConsultField(
                label: 'Semanas de gestación (SDG)',
                controller: gestWeeksCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                hint: 'Dejar vacío si no aplica',
              ),
            ],
          ),

          // Seguimiento de peso
          FormSection(
            title: 'Seguimiento de Peso',
            icon: Icons.monitor_weight_outlined,
            children: [
              ConsultField(
                label: 'Pre-gestacional (kg)',
                controller: pregestCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              ConsultField(
                label: 'Habitual (kg)',
                controller: usualWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              ConsultField(
                label: 'Actual (kg)',
                controller: currentWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),

          // IMC calculado
          if (imcValue.value != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(context.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IMC PREGESTACIONAL',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(imcValue.value!.toStringAsFixed(1),
                          style: context.textTheme.displayMedium?.copyWith(
                              color: context.colors.onSurface)),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: imcColor(imcValue.value!, context)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            imcCategory(imcValue.value!),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: imcColor(imcValue.value!, context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Perímetros
          FormSection(
            title: 'Perímetros y Pliegues',
            icon: Icons.straighten_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ConsultField(
                      label: 'Cintura (cm)',
                      controller: waistCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ConsultField(
                      label: 'Cadera (cm)',
                      controller: hipCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ConsultField(
                      label: 'P. Brazo (cm)',
                      controller: armCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ConsultField(
                      label: 'Pliegue tríceps (mm)',
                      controller: tricepsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
