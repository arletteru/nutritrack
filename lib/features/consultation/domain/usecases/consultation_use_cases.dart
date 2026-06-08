import '../entities/consultation_entity.dart';
import '../repositories/i_consultation_repository.dart';

class CreateConsultationUseCase {
  final IConsultationRepository _repo;
  const CreateConsultationUseCase(this._repo);
  Future<String> call({
    required String patientId,
    required String patientUid,
    required String nutriologistId,
    required ConsultationType type,
    String? appointmentId,
  }) => _repo.createConsultation(
        patientId: patientId,
        patientUid: patientUid,
        nutriologistId: nutriologistId,
        type: type,
        appointmentId: appointmentId,
      );
}

class SaveConsultationStepUseCase {
  final IConsultationRepository _repo;
  const SaveConsultationStepUseCase(this._repo);
  Future<void> call({
    required String consultationId,
    required int stepNumber,
    required Map<String, dynamic> data,
  }) => _repo.saveStep(
        consultationId: consultationId,
        stepNumber: stepNumber,
        data: data,
      );
}

class CompleteConsultationUseCase {
  final IConsultationRepository _repo;
  const CompleteConsultationUseCase(this._repo);
  Future<void> call(String consultationId) => _repo.completeConsultation(consultationId);
}

class WatchPatientConsultationsUseCase {
  final IConsultationRepository _repo;
  const WatchPatientConsultationsUseCase(this._repo);
  Stream<List<Map<String, dynamic>>> call(String patientId) =>
      _repo.watchPatientConsultations(patientId);
}
