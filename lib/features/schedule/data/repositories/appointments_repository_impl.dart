import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/i_appointments_repository.dart';
import '../datasources/appointments_firestore_datasource.dart';

class AppointmentsRepositoryImpl implements IAppointmentsRepository {
  final IAppointmentsDataSource _ds;
  const AppointmentsRepositoryImpl(this._ds);

  @override
  Stream<List<AppointmentEntity>> watchUpcomingForNutrologist(String id) =>
      _ds.watchUpcomingForNutrologist(id).map((l) => l.map((m) => m.toEntity()).toList());

  @override
  Stream<List<AppointmentEntity>> watchTodayForNutrologist(String id) =>
      _ds.watchTodayForNutrologist(id).map((l) => l.map((m) => m.toEntity()).toList());

  @override
  Stream<AppointmentEntity?> watchNextForPatient(String id) =>
      _ds.watchNextForPatient(id).map((m) => m?.toEntity());

  @override
  Future<void> createAppointment(Map<String, dynamic> data) =>
      _ds.createAppointment(data);

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) =>
      _ds.updateStatus(id, status.name);
}
