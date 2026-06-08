import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/features/consultation/presentation/notifiers/consultation_wizard_notifier.dart';
import 'package:nutritrack/features/consultation/presentation/widgets/generate_plan_dialog.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
 import '../widgets/step1_metadata_form.dart';
import '../widgets/step2_anthropometry_form.dart';
import '../widgets/step3_biochemical_form.dart';
import '../widgets/step4_dietary_form.dart';
import '../widgets/step5_recall24h_form.dart';
import '../widgets/step6_diagnosis_form.dart';


class ConsultationWizardPage extends HookConsumerWidget {
  const ConsultationWizardPage({
    super.key,
    required this.patientId,
    required this.patientUid,
    this.appointmentId,
    this.existingConsultationId,
    this.patientName,
    this.patientExpediente,
  });

  final String patientId;
  final String patientUid;
  final String? appointmentId;
  final String? existingConsultationId;
   final String? patientName;
  final String? patientExpediente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizard = ref.watch(consultationWizardProvider);
    final notifier = ref.read(consultationWizardProvider.notifier);

    useEffect(() {
      if (wizard.consultationId == null) {
        Future.microtask(() async {
          final user = ref.read(authStateChangesProvider).value;
          if (user == null) return;

          if (existingConsultationId != null){
            await notifier.loadExisting(
              consultationId: existingConsultationId!,
            );
          } else {
            if (wizard.consultationId == null){
              notifier.prepareNewConsultation(
                patientId: patientId,
                patientUid: patientUid,
                nutriologistId: user.uid,
                appointmentId: appointmentId,
                patientName: patientName,
                patientExpediente: patientExpediente,
              );
            }
          } 
        });
      }
      return null;
    }, [existingConsultationId]);

    ref.listen(consultationWizardProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ));
        notifier.clearError();
      }
    });

    final step = wizard.currentStep.clamp(1, 6);

    return PopScope(
      canPop: step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.goBack();
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => step == 1 ? context.pop() : notifier.goBack(),
          ),
          title: const Text('Historial Clínico'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: _WizardProgressBar(currentStep: step),
          ),
        ),
        body: _StepBody(
          step: step,
          isSaving: wizard.isSaving,
          existingData: wizard.stepData[step],
          prefilledName: wizard.pendingPatientName,
          prefilledExpediente: wizard.pendingPatientExpediente,
          onNext: (data) => notifier.saveAndAdvance(step: step, data: data),
          onFinish: (step6Data) async {
            // 1. Guardar paso 6 y completar consulta
            final ok = await notifier.finishConsultation(step6Data);
            if (!ok || !context.mounted) return;

            // 2. Mostrar diálogo para generar plan
            final consultationId = wizard.consultationId;
            if (consultationId == null) {
              context.pop();
              return;
            }

            final generated = await GeneratePlanDialog.show(
              context,
              patientId: wizard.pendingPatientId ?? '',
              patientUid: wizard.pendingPatientUid ?? '',
              nutriologistId: wizard.pendingNutriologistId ?? '',
              consultationId: consultationId,
              step6Data: step6Data,
            );

            if (!context.mounted) return;

            // 3. Navegar al historial del paciente o al home
            if (generated) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Consulta y plan generados correctamente'),
                backgroundColor: context.nutri.success,
                behavior: SnackBarBehavior.floating,
              ));
            }

            // Volver al detalle del paciente
            context.pop();
          },
        ),

              ),
    );
  }
}

class _WizardProgressBar extends StatelessWidget {
  const _WizardProgressBar({required this.currentStep});
  final int currentStep;

  static const _labels = ['Metadatos','Antrop.','Bioquím.','Dietética','24 hrs','Dx PES'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(6, (i) {
              final isDone = (i + 1) < currentStep;
              final isActive = (i + 1) == currentStep;
              return Expanded(
                child: Row(children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isDone || isActive
                            ? context.colors.primary
                            : context.colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  if (i < 5) const SizedBox(width: 2),
                ]),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PASO $currentStep DE 6',
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary, letterSpacing: 0.8)),
              Text(_labels[currentStep - 1],
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.step,
    required this.isSaving,
    required this.existingData,
    required this.onNext,
    required this.onFinish,
    this.prefilledName,        
    this.prefilledExpediente,  
  });

  final int step;
  final bool isSaving;
  final Map<String, dynamic>? existingData;
  final Future<bool> Function(Map<String, dynamic>) onNext;
  final Future<void> Function(Map<String, dynamic>) onFinish;
  final String? prefilledName;        
  final String? prefilledExpediente;  

  @override
  Widget build(BuildContext context) => switch (step) {
    1 => Step1MetadataForm(
        initialData: existingData,
        isSaving: isSaving,
        onNext: onNext,
        prefilledName: prefilledName,             
        prefilledExpediente: prefilledExpediente, 
      ),
    2 => Step2AnthropometryForm(initialData: existingData, isSaving: isSaving, onNext: onNext),
    3 => Step3BiochemicalForm(initialData: existingData, isSaving: isSaving, onNext: onNext),
    4 => Step4DietaryForm(initialData: existingData, isSaving: isSaving, onNext: onNext),
    5 => Step5Recall24hForm(initialData: existingData, isSaving: isSaving, onNext: onNext),
    6 => Step6DiagnosisForm(initialData: existingData, isSaving: isSaving, onFinish: onFinish),
    _ => const SizedBox.shrink(),
  };
}