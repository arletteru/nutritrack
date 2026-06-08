import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import 'step_scaffold.dart';

class Step1MetadataForm extends HookWidget {
  const Step1MetadataForm({
    super.key,
    required this.onNext,
    required this.isSaving,
    this.initialData,
    this.prefilledName,
    this.prefilledExpediente,
  });

  final Future<bool> Function(Map<String, dynamic>) onNext;
  final bool isSaving;
  final Map<String, dynamic>? initialData;
  final String? prefilledName;
  final String? prefilledExpediente;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final dateCtrl = useTextEditingController(
        text: initialData?['consultationDate'] ??
            DateFormat('MM/dd/yyyy').format(DateTime.now()));
    final timeCtrl = useTextEditingController(
        text: initialData?['consultationTime'] ??
            DateFormat('hh:mm a').format(DateTime.now()));
    final expedienteCtrl = useTextEditingController(
        text: initialData?['expediente'] ?? prefilledExpediente ?? '',);
    final nameCtrl = useTextEditingController(
      text: initialData?['fullName'] ?? prefilledName ?? '',
    );

    useEffect(() {
      if (nameCtrl.text.isEmpty && prefilledName != null) {
        nameCtrl.text = prefilledName!;
      }
      return null;
    }, [prefilledName]);

    useEffect(() {
      if (expedienteCtrl.text.isEmpty && prefilledExpediente != null) {
        expedienteCtrl.text = prefilledExpediente!;
      }
      return null;
    }, [prefilledExpediente]);

    final ageCtrl = useTextEditingController(
        text: initialData?['age']?.toString() ?? '');
    final consultType = useState<String>(
        initialData?['consultType'] ?? 'Primera vez');
    final isPregnant = useState<bool>(initialData?['isPregnant'] ?? false);
    final isMinor = useState<bool>(initialData?['isMinor'] ?? false);
    final referralCtrl = useTextEditingController(
        text: initialData?['referralReason'] ?? '');
    final occupationCtrl = useTextEditingController(
        text: initialData?['occupation'] ?? '');
    final educationCtrl = useTextEditingController(
        text: initialData?['educationLevel'] ?? '');
    final supportCtrl = useTextEditingController(
        text: initialData?['supportNetwork'] ?? '');

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        dateCtrl.text = DateFormat('MM/dd/yyyy').format(picked);
      }
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        timeCtrl.text = picked.format(context);
      }
    }

    return Form(
      key: formKey,
      child: StepScaffold(
        title: 'Historial\nClínico',
        isSaving: isSaving,
        onNext: () {
          if (formKey.currentState?.validate() ?? false) {
            onNext({
              'consultationDate': dateCtrl.text,
              'consultationTime': timeCtrl.text,
              'expediente': expedienteCtrl.text,
              'fullName': nameCtrl.text,
              'age': int.tryParse(ageCtrl.text) ?? 0,
              'consultType': consultType.value,
              'isPregnant': isPregnant.value,
              'isMinor': isMinor.value,
              'referralReason': referralCtrl.text,
              'occupation': occupationCtrl.text,
              'educationLevel': educationCtrl.text,
              'supportNetwork': supportCtrl.text,
            });
          }
        },
        children: [
          // Metadatos
          FormSection(
            title: 'Metadatos',
            icon: Icons.calendar_today_outlined,
            children: [
              ConsultField(
                label: 'Fecha de consulta',
                controller: dateCtrl,
                readOnly: true,
                onTap: pickDate,
                suffix: const Icon(Icons.calendar_month_outlined, size: 20),
              ),
              ConsultField(
                label: 'Hora',
                controller: timeCtrl,
                readOnly: true,
                onTap: pickTime,
                suffix: const Icon(Icons.access_time_outlined, size: 20),
              ),
            ],
          ),

          // Identificación
          FormSection(
            title: 'Identificación del Paciente',
            icon: Icons.badge_outlined,
            children: [
              ConsultField(
                label: 'Expediente',
                controller: expedienteCtrl,
                hint: 'ID-00234',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              ConsultField(
                label: 'Nombre completo',
                controller: nameCtrl,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: ConsultField(
                      label: 'Edad exacta',
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Años',
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant)),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Clasificación
          FormSection(
            title: 'Clasificación de Atención',
            subtitle: 'Define el perfil clínico prioritario para esta sesión.',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo de consulta',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(context.radiusMd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: consultType.value,
                        isExpanded: true,
                        items: ['Primera vez', 'Seguimiento', 'Control']
                            .map((v) => DropdownMenuItem(
                                value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) consultType.value = v;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              ConsultToggle(
                label: 'Embarazo',
                value: isPregnant.value,
                onChanged: (v) => isPregnant.value = v,
              ),
              ConsultToggle(
                label: 'Menor de 18',
                value: isMinor.value,
                onChanged: (v) => isMinor.value = v,
              ),
            ],
          ),

          // Contexto social
          FormSection(
            title: 'Contexto Social',
            icon: Icons.people_outline,
            children: [
              ConsultField(
                label: 'Motivo de interconsulta',
                controller: referralCtrl,
                hint: 'Describa el motivo médico o personal...',
                maxLines: 3,
              ),
              ConsultField(
                label: 'Ocupación',
                controller: occupationCtrl,
                textInputAction: TextInputAction.next,
              ),
              ConsultField(
                label: 'Escolaridad',
                controller: educationCtrl,
                textInputAction: TextInputAction.next,
              ),
              ConsultField(
                label: 'Red de apoyo',
                controller: supportCtrl,
                hint: 'Familiar, pareja, comunidad...',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
