import '../entities/recommendation_entity.dart';
import '../repositories/i_recommendations_repository.dart';

class WatchLatestRecommendationUseCase {
  final IRecommendationsRepository _repo;
  const WatchLatestRecommendationUseCase(this._repo);
  Stream<RecommendationEntity?> call(String patientId) =>
      _repo.watchLatestForPatient(patientId);
}
