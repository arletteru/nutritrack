// features/consultation/presentation/notifiers/consultation_wizard_notifier.dart
//
// CAPA: Presentation

import 'package:nutritrack/features/consultation/presentation/providers/consultation_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../consultation/domain/entities/consultation_entity.dart';
import '../states/consultation_wizard_state.dart';

part 'consultation_wizard_notifier.g.dart';

@riverpod
class ConsultationWizardNotifier extends _$ConsultationWizardNotifier {
  @override
  ConsultationWizardState build() => const ConsultationWizardState();

  /// Prepara los datos del paciente pero NO crea nada en Firestore todavía.
  /// La consulta se crea al primer saveAndAdvance.
  void prepareNewConsultation({
    required String patientId,
    required String patientUid,
    required String nutriologistId,
    String? appointmentId,
    String? patientName,
    String? patientExpediente,
  }) {
    state = state.copyWith(
      pendingPatientId: patientId,
      pendingPatientUid: patientUid,
      pendingNutriologistId: nutriologistId,
      pendingAppointmentId: appointmentId,
      pendingPatientName: patientName,
      pendingPatientExpediente: patientExpediente,
      consultationId: null,
      currentStep: 1,
      stepData: {},
      errorMessage: null,
    );
  }

  /// Carga una consulta existente para continuar.
  Future<void> loadExisting({required String consultationId}) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final stepsData = <int, Map<String, dynamic>>{};
      for (int i = 1; i <= 6; i++) {
        final step = await repo.getStep(consultationId, i);
        if (step != null) stepsData[i] = step;
      }
      final currentStep = stepsData.isEmpty
          ? 1
          : stepsData.keys.reduce((a, b) => a > b ? a : b) + 1;

      state = state.copyWith(
        consultationId: consultationId,
        currentStep: currentStep.clamp(1, 6),
        stepData: stepsData,
        isSaving: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
    }
  }

  /// Guarda el paso actual y avanza.
  /// Si es el primer paso y no hay consultationId, crea la consulta primero.
  Future<bool> saveAndAdvance({
    required int step,
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final repo = ref.read(consultationRepositoryProvider);

      // ── Creación lazy: solo si no existe aún ──────────────────────────────
      if (state.consultationId == null) {
        final typeStr = data['consultType'] as String? ?? 'Primera vez';
        final type = typeStr == 'Primera vez'
            ? ConsultationType.first
            : ConsultationType.followUp;

        final id = await repo.createConsultation(
          patientId: state.pendingPatientId ?? '',
          patientUid: state.pendingPatientUid ?? '',
          nutriologistId: state.pendingNutriologistId ?? '',
          type: type,
          appointmentId: state.pendingAppointmentId,
        );
        state = state.copyWith(consultationId: id);
      }

      // ── Guardar el paso ───────────────────────────────────────────────────
      await repo.saveStep(
        consultationId: state.consultationId!,
        stepNumber: step,
        data: data,
      );

      state = state.copyWith(
        isSaving: false,
        currentStep: step + 1,
        stepData: {...state.stepData, step: data},
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return false;
    }
  }

  Future<bool> finishConsultation(Map<String, dynamic> step6Data) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      // Si por alguna razón no se creó aún, crear ahora
      final repo = ref.read(consultationRepositoryProvider);
      if (state.consultationId == null) {
        final id = await repo.createConsultation(
          patientId: state.pendingPatientId ?? '',
          patientUid: state.pendingPatientUid ?? '',
          nutriologistId: state.pendingNutriologistId ?? '',
          type: ConsultationType.first,
        );
        state = state.copyWith(consultationId: id);
      }

      await repo.saveStep(
        consultationId: state.consultationId!,
        stepNumber: 6,
        data: step6Data,
      );
      await repo.completeConsultation(state.consultationId!);
      state = state.copyWith(isSaving: false, currentStep: 6);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return false;
    }
  }

  void goBack() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}