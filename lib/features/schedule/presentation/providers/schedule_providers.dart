import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/appointments_firestore_datasource.dart';
import '../../data/repositories/appointments_repository_impl.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/i_appointments_repository.dart';
import '../../domain/usecases/schedule_use_cases.dart';

part 'schedule_providers.g.dart';

@Riverpod(keepAlive: true)
IAppointmentsDataSource appointmentsDataSource(Ref ref) =>
    AppointmentsFirestoreDataSource();

@Riverpod(keepAlive: true)
IAppointmentsRepository appointmentsRepository(Ref ref) =>
    AppointmentsRepositoryImpl(ref.watch(appointmentsDataSourceProvider));

@riverpod
Stream<List<AppointmentEntity>> watchUpcomingAppointments(
    Ref ref, String nutriologistId) =>
    WatchUpcomingAppointmentsUseCase(ref.watch(appointmentsRepositoryProvider))
        .call(nutriologistId);

@riverpod
Stream<List<AppointmentEntity>> watchTodayAppointments(
    Ref ref, String nutriologistId) =>
    WatchTodayAppointmentsUseCase(ref.watch(appointmentsRepositoryProvider))
        .call(nutriologistId);

@riverpod
Stream<AppointmentEntity?> watchNextPatientAppointment(
    Ref ref, String patientId) =>
    WatchNextPatientAppointmentUseCase(ref.watch(appointmentsRepositoryProvider))
        .call(patientId);
