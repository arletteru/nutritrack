import '../entities/appointment_entity.dart';

abstract class IAppointmentsRepository {
  Stream<List<AppointmentEntity>> watchUpcomingForNutrologist(String nutriologistId);
  Stream<List<AppointmentEntity>> watchTodayForNutrologist(String nutriologistId);
  Stream<AppointmentEntity?> watchNextForPatient(String patientId);
  Future<void> createAppointment(Map<String, dynamic> data);
  Future<void> updateStatus(String id, AppointmentStatus status);
}
