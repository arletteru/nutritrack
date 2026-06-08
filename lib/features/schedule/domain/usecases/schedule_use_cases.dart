import '../entities/appointment_entity.dart';
import '../repositories/i_appointments_repository.dart';

class WatchUpcomingAppointmentsUseCase {
  final IAppointmentsRepository _repo;
  const WatchUpcomingAppointmentsUseCase(this._repo);
  Stream<List<AppointmentEntity>> call(String nutriologistId) =>
      _repo.watchUpcomingForNutrologist(nutriologistId);
}

class WatchTodayAppointmentsUseCase {
  final IAppointmentsRepository _repo;
  const WatchTodayAppointmentsUseCase(this._repo);
  Stream<List<AppointmentEntity>> call(String nutriologistId) =>
      _repo.watchTodayForNutrologist(nutriologistId);
}

class WatchNextPatientAppointmentUseCase {
  final IAppointmentsRepository _repo;
  const WatchNextPatientAppointmentUseCase(this._repo);
  Stream<AppointmentEntity?> call(String patientId) =>
      _repo.watchNextForPatient(patientId);
}

class CreateAppointmentUseCase {
  final IAppointmentsRepository _repo;
  const CreateAppointmentUseCase(this._repo);
  Future<void> call(Map<String, dynamic> data) => _repo.createAppointment(data);
}
