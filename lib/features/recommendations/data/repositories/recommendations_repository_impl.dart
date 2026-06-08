import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/i_recommendations_repository.dart';
import '../datasources/recommendations_firestore_datasource.dart';

class RecommendationsRepositoryImpl implements IRecommendationsRepository {
  final IRecommendationsDataSource _ds;
  const RecommendationsRepositoryImpl(this._ds);

  @override
  Stream<RecommendationEntity?> watchLatestForPatient(String patientId) =>
      _ds.watchLatestForPatient(patientId).map((m) => m?.toEntity());

  @override
  Future<void> saveRecommendation(RecommendationEntity rec) =>
      _ds.saveRecommendation(rec.toFirestore());
}

extension on RecommendationEntity {
  Map<String, dynamic> toFirestore() => {
    'patientId': patientId,
    'nutriologistId': nutriologistId,
    'consultationId': consultationId,
    'dietGuidelines': dietGuidelines,
    'habits': habits,
    'goals': goals,
    'additionalNotes': additionalNotes,
  };
}
