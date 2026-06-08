import '../entities/consultation_entity.dart';

abstract class IConsultationRepository {
  Future<String> createConsultation({
    required String patientId,
    required String patientUid,
    required String nutriologistId,
    required ConsultationType type,
    String? appointmentId,
  });
  Future<void> saveStep({
    required String consultationId,
    required int stepNumber,
    required Map<String, dynamic> data,
  });
  Future<void> completeConsultation(String consultationId);
  Stream<List<Map<String, dynamic>>> watchPatientConsultations(String patientId);
  Stream<List<Map<String, dynamic>>> watchConsultationsByNutriologist({required String patientId,required String nutriologistId,});
  Future<Map<String, dynamic>?> getStep(String consultationId, int stepNumber);
}
