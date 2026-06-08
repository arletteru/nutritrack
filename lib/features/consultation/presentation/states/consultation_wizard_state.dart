// features/consultation/presentation/states/consultation_wizard_state.dart
//
// CAPA: Presentation — estado del wizard de consulta.
// Freezed reemplaza el copyWith que estaba escrito a mano.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_wizard_state.freezed.dart';

@freezed
abstract class ConsultationWizardState with _$ConsultationWizardState {
  const factory ConsultationWizardState({
    /// ID del documento en Firestore, null hasta que se crea.
    String? consultationId,

    /// Paso actual (1–6).
    @Default(1) int currentStep,

    /// Datos de cada paso ya guardados. Key = número de paso.
    @Default({}) Map<int, Map<String, dynamic>> stepData,

    /// True mientras hay una operación en curso con Firestore.
    @Default(false) bool isSaving,

    /// Mensaje de error a mostrar en la UI. null si no hay error.
    String? errorMessage,

    // ── Datos del paciente para crear la consulta al primer "Siguiente"
    String? pendingPatientId,
    String? pendingPatientUid,
    String? pendingNutriologistId,
    String? pendingAppointmentId,
    String? pendingPatientName,
    String? pendingPatientExpediente,
  }) = _ConsultationWizardState;
}
