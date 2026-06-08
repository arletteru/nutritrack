import '../entities/patient_entity.dart';

abstract class IPatientsRepository {
  Stream<List<PatientEntity>> watchPatients(String nutriologistId);
  Future<PatientEntity?> getPatient(String patientId);
  Future<void> createPatient({
    required String fullName,
    required String email,
    required String expediente,
    required String nutriologistId,
  });
  Future<void> updatePatient(String patientId, Map<String, dynamic> data);
  Future<void> syncPatientHistory({
    required String patientDocId,
    required String patientUid,
    required String nutriologistId,
  });
}
