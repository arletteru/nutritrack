import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/patients_firestore_datasource.dart';
import '../../data/repositories/patients_repository_impl.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/i_patients_repository.dart';
import '../../domain/usecases/patients_use_cases.dart';

part 'patients_providers.g.dart';

@Riverpod(keepAlive: true)
IPatientsDataSource patientsDataSource(Ref ref) =>
    PatientsFirestoreDataSource();

@Riverpod(keepAlive: true)
IPatientsRepository patientsRepository(Ref ref) =>
    PatientsRepositoryImpl(ref.watch(patientsDataSourceProvider));

@riverpod
WatchPatientsUseCase watchPatientsUseCase(Ref ref) =>
    WatchPatientsUseCase(ref.watch(patientsRepositoryProvider));

@riverpod
GetPatientUseCase getPatientUseCase(Ref ref) =>
    GetPatientUseCase(ref.watch(patientsRepositoryProvider));

@riverpod
CreatePatientUseCase createPatientUseCase(Ref ref) =>
    CreatePatientUseCase(ref.watch(patientsRepositoryProvider));

// ── Stream provider ───────────────────────────────────────────────────────────
@riverpod
Stream<List<PatientEntity>> watchPatients(
    Ref ref, String nutriologistId) =>
    ref.watch(watchPatientsUseCaseProvider).call(nutriologistId);
