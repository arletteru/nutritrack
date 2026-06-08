import '../entities/recommendation_entity.dart';

abstract class IRecommendationsRepository {
  Stream<RecommendationEntity?> watchLatestForPatient(String patientId);
  Future<void> saveRecommendation(RecommendationEntity recommendation);
}
