import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/recommendations_firestore_datasource.dart';
import '../../data/repositories/recommendations_repository_impl.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/repositories/i_recommendations_repository.dart';
import '../../domain/usecases/recommendations_use_cases.dart';

part 'recommendations_providers.g.dart';

@Riverpod(keepAlive: true)
IRecommendationsDataSource recommendationsDataSource(Ref ref) =>
    RecommendationsFirestoreDataSource();

@Riverpod(keepAlive: true)
IRecommendationsRepository recommendationsRepository(Ref ref) =>
    RecommendationsRepositoryImpl(ref.watch(recommendationsDataSourceProvider));

// En recommendations_providers.dart — temporalmente
@riverpod
Stream<RecommendationEntity?> watchLatestRecommendation(
  Ref ref,
  String patientId,
) {
  debugPrint('watchLatestRecommendation — patientId: $patientId');
  return WatchLatestRecommendationUseCase(
    ref.watch(recommendationsRepositoryProvider),
  ).call(patientId).map((entity) {
    debugPrint('entity: ${entity?.id} macroMods: ${entity?.macroModifications.length}');
    return entity;
  });
}