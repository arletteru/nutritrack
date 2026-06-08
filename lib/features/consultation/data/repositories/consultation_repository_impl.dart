import '../../domain/entities/consultation_entity.dart';
import '../../domain/repositories/i_consultation_repository.dart';
import '../datasources/consultation_firestore_datasource.dart';

class ConsultationRepositoryImpl implements IConsultationRepository {
  final IConsultationDataSource _ds;
  const ConsultationRepositoryImpl(this._ds);

  @override
  Future<String> createConsultation({
    required String patientId,
    required String patientUid,
    required String nutriologistId,
    required ConsultationType type,
    String? appointmentId,
  }) =>
      _ds.createConsultation({
        'patientId': patientId,
        'patientUid': patientUid,
        'nutriologistId': nutriologistId,
        'type': type.name,
        'status': ConsultationStatus.draft.name,
        'currentStep': 1,
        'appointmentId': appointmentId,
      });

  @override
  Future<void> saveStep({required String consultationId, required int stepNumber, required Map<String, dynamic> data}) =>
      _ds.saveStep(consultationId: consultationId, stepNumber: stepNumber, data: data);

  @override
  Future<void> completeConsultation(String consultationId) =>
      _ds.completeConsultation(consultationId);

  @override
  Stream<List<Map<String, dynamic>>> watchPatientConsultations(String patientId) =>
      _ds.watchPatientConsultations(patientId);

  @override
  Future<Map<String, dynamic>?> getStep(String consultationId, int stepNumber) =>
      _ds.getStep(consultationId, stepNumber);
      
  @override
  Stream<List<Map<String, dynamic>>> watchConsultationsByNutriologist({required String patientId, required String nutriologistId}) =>
      _ds.watchConsultationsByNutriologist( patientId: patientId, nutriologistId: nutriologistId);
}
