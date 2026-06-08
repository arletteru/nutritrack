import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';

class WatchPatientsUseCase {
  final IPatientsRepository _repo;
  const WatchPatientsUseCase(this._repo);
  Stream<List<PatientEntity>> call(String nutriologistId) =>
      _repo.watchPatients(nutriologistId);
}

class GetPatientUseCase {
  final IPatientsRepository _repo;
  const GetPatientUseCase(this._repo);
  Future<PatientEntity?> call(String patientId) => _repo.getPatient(patientId);
}

class CreatePatientUseCase {
  final IPatientsRepository _repo;
  const CreatePatientUseCase(this._repo);
  Future<void> call({
    required String fullName,
    required String email,
    required String expediente,
    required String nutriologistId,
  }) =>
      _repo.createPatient(
        fullName: fullName,
        email: email,
        expediente: expediente,
        nutriologistId: nutriologistId,
      );
}
