// ── Step 3: Bioquímicos ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'step_scaffold.dart';

class Step3BiochemicalForm extends HookWidget {
  const Step3BiochemicalForm({
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
    final glucoseCtrl = useTextEditingController(text: initialData?['glucose']?.toString() ?? '');
    final hba1cCtrl = useTextEditingController(text: initialData?['hba1c']?.toString() ?? '');
    final cholCtrl = useTextEditingController(text: initialData?['totalCholesterol']?.toString() ?? '');
    final hdlCtrl = useTextEditingController(text: initialData?['hdl']?.toString() ?? '');
    final ldlCtrl = useTextEditingController(text: initialData?['ldl']?.toString() ?? '');
    final triglCtrl = useTextEditingController(text: initialData?['triglycerides']?.toString() ?? '');
    final hemoCtrl = useTextEditingController(text: initialData?['hemoglobin']?.toString() ?? '');
    final ferritinCtrl = useTextEditingController(text: initialData?['ferritin']?.toString() ?? '');
    final creatCtrl = useTextEditingController(text: initialData?['creatinine']?.toString() ?? '');
    final obsCtrl = useTextEditingController(text: initialData?['observations'] ?? '');

    return Form(
      key: formKey,
      child: StepScaffold(
        title: 'Bioquímicos',
        subtitle: 'Resultados de laboratorio recientes del paciente.',
        isSaving: isSaving,
        onNext: () => onNext({
          'glucose': double.tryParse(glucoseCtrl.text),
          'hba1c': double.tryParse(hba1cCtrl.text),
          'totalCholesterol': double.tryParse(cholCtrl.text),
          'hdl': double.tryParse(hdlCtrl.text),
          'ldl': double.tryParse(ldlCtrl.text),
          'triglycerides': double.tryParse(triglCtrl.text),
          'hemoglobin': double.tryParse(hemoCtrl.text),
          'ferritin': double.tryParse(ferritinCtrl.text),
          'creatinine': double.tryParse(creatCtrl.text),
          'observations': obsCtrl.text,
        }),
        children: [
          FormSection(title: 'Glucosa y HbA1c', icon: Icons.water_drop_outlined, children: [
            Row(children: [
              Expanded(child: ConsultField(label: 'Glucosa basal (mg/dL)', controller: glucoseCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: ConsultField(label: 'HbA1c (%)', controller: hba1cCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ]),
          ]),
          FormSection(title: 'Perfil Lipídico', icon: Icons.favorite_outline, children: [
            Row(children: [
              Expanded(child: ConsultField(label: 'Col. total (mg/dL)', controller: cholCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: ConsultField(label: 'HDL (mg/dL)', controller: hdlCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ]),
            Row(children: [
              Expanded(child: ConsultField(label: 'LDL (mg/dL)', controller: ldlCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: ConsultField(label: 'Triglicéridos (mg/dL)', controller: triglCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ]),
          ]),
          FormSection(title: 'Hematología y Renal', icon: Icons.biotech_outlined, children: [
            Row(children: [
              Expanded(child: ConsultField(label: 'Hemoglobina (g/dL)', controller: hemoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: ConsultField(label: 'Ferritina (ng/mL)', controller: ferritinCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ]),
            ConsultField(label: 'Creatinina (mg/dL)', controller: creatCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ]),
          FormSection(title: 'Observaciones', children: [
            ConsultField(label: 'Notas clínicas', controller: obsCtrl, maxLines: 4,
                hint: 'Ej. Glucosa basal 105 mg/dl...'),
          ]),
        ],
      ),
    );
  }
}
