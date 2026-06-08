import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/i_patients_repository.dart';
import '../datasources/patients_firestore_datasource.dart';

class PatientsRepositoryImpl implements IPatientsRepository {
  final IPatientsDataSource _ds;
  const PatientsRepositoryImpl(this._ds);

  @override
  Stream<List<PatientEntity>> watchPatients(String nutriologistId) =>
      _ds.watchPatients(nutriologistId).map((list) => list.map((m) => m.toEntity()).toList());

  @override
  Future<PatientEntity?> getPatient(String patientId) async {
    final model = await _ds.getPatient(patientId);
    return model?.toEntity();
  }

  @override
  Future<void> createPatient({
    required String fullName,
    required String email,
    required String expediente,
    required String nutriologistId,
  }) =>
      _ds.createPatient({
        'fullName': fullName,
        'email': email,
        'expediente': expediente,
        'nutriologistId': nutriologistId,
        'uid': '',
        'status': 'active',
      });

  @override
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) =>
      _ds.updatePatient(patientId, data);

  @override
  Future<void> syncPatientHistory({
    required String patientDocId,
    required String patientUid,
    required String nutriologistId,
  }) =>
    _ds.syncPatientHistory(
    patientDocId: patientDocId,
    patientUid: patientUid,
    nutriologistId: nutriologistId,
  );
}
