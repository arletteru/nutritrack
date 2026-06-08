import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_entity.freezed.dart';

@freezed
abstract class MacroPlan with _$MacroPlan {
  const factory MacroPlan({
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required int totalKcal,
  }) = _MacroPlan;
}

@freezed
abstract class RecommendationEntity with _$RecommendationEntity {
  const factory RecommendationEntity({
    required String id,
    required String patientId,
    @Default('') String patientUid,
    required String nutriologistId,
    required String consultationId,
    MacroPlan? macroPlan,
    // ── Campo nuevo: guarda las modificaciones del paso 6 tal como
    //    las guardó GeneratePlanNotifier en Firestore
    @Default([]) List<Map<String, dynamic>> macroModifications,
    @Default([]) List<String> dietGuidelines,
    @Default([]) List<String> habits,
    @Default([]) List<String> goals,
    String? additionalNotes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecommendationEntity;
}
