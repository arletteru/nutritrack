import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/consultation_firestore_datasource.dart';
import '../../data/repositories/consultation_repository_impl.dart';
import '../../domain/repositories/i_consultation_repository.dart';
import '../../domain/usecases/consultation_use_cases.dart';

part 'consultation_providers.g.dart';

@Riverpod(keepAlive: true)
IConsultationDataSource consultationDataSource(Ref ref) =>
    ConsultationFirestoreDataSource();

@Riverpod(keepAlive: true)
IConsultationRepository consultationRepository(Ref ref) =>
    ConsultationRepositoryImpl(ref.watch(consultationDataSourceProvider));

@riverpod
CreateConsultationUseCase createConsultationUseCase(Ref ref) =>
    CreateConsultationUseCase(ref.watch(consultationRepositoryProvider));

@riverpod
SaveConsultationStepUseCase saveConsultationStepUseCase(Ref ref) =>
    SaveConsultationStepUseCase(ref.watch(consultationRepositoryProvider));

@riverpod
CompleteConsultationUseCase completeConsultationUseCase(Ref ref) =>
    CompleteConsultationUseCase(ref.watch(consultationRepositoryProvider));

@riverpod
Stream<Map<String, dynamic>?> watchLatestPatientConsultation(
  Ref ref,
  String patientId,
) =>
    ref
        .watch(consultationRepositoryProvider)
        .watchPatientConsultations(patientId)
        .map((list) => list.isEmpty ? null : list.first);

@riverpod
Stream<List<Map<String, dynamic>>> watchConsultationsByNutriologist(
  Ref ref, {
  required String patientId,
  required String nutriologistId,
}) =>
    ref
        .watch(consultationRepositoryProvider)
        .watchConsultationsByNutriologist(
          patientId: patientId,
          nutriologistId: nutriologistId,
        );