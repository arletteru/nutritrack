import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/recommendation_entity.dart';

part 'recommendation_model.freezed.dart';
part 'recommendation_model.g.dart';

@freezed
abstract class MacroPlanModel with _$MacroPlanModel {
  const MacroPlanModel._();

  const factory MacroPlanModel({
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required int totalKcal,
  }) = _MacroPlanModel;

  factory MacroPlanModel.fromJson(Map<String, dynamic> json) =>
      _$MacroPlanModelFromJson(json);

  MacroPlan toEntity() => MacroPlan(
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatGrams: fatGrams,
        totalKcal: totalKcal,
      );
}

@freezed
abstract class RecommendationModel with _$RecommendationModel {
  const RecommendationModel._();

  const factory RecommendationModel({
    required String id,
    required String patientId,
    @Default('') String patientUid,          
    required String nutriologistId,
    required String consultationId,
    MacroPlanModel? macroPlan,
    // ── Modificaciones crudas del paso 6 ──────────────────────────────────
    @Default([]) List<Map<String, dynamic>> macroModifications, 
    @Default([]) List<String> dietGuidelines,
    @Default([]) List<String> habits,
    @Default([]) List<String> goals,
    String? additionalNotes,
    required String createdAt,
    required String updatedAt,
  }) = _RecommendationModel;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationModelFromJson(json);

  factory RecommendationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;

    // ── MacroPlan clásico (proteinGrams etc.) si existe ───────────────────
    MacroPlanModel? macro;
    final macroPlanRaw = d['macroPlan'] as Map<String, dynamic>?;
    if (macroPlanRaw != null && macroPlanRaw.containsKey('proteinGrams')) {
      // Formato clásico — tiene proteinGrams, carbsGrams, etc.
      try {
        macro = MacroPlanModel.fromJson(macroPlanRaw);
      } catch (_) {}
    }

    // ── Modificaciones del paso 6 (formato nuevo del GeneratePlanNotifier)
    // El GeneratePlanNotifier guarda:
    // macroPlan: { modifications: [...], generatedAt: ... }
    List<Map<String, dynamic>> modifications = [];
    if (macroPlanRaw != null && macroPlanRaw.containsKey('modifications')) {
      modifications = List<Map<String, dynamic>>.from(
        (macroPlanRaw['modifications'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }

    return RecommendationModel(
      id: doc.id,
      patientId: d['patientId'] as String? ?? '',
      patientUid: d['patientUid'] as String? ?? '',  // ← nuevo
      nutriologistId: d['nutriologistId'] as String? ?? '',
      consultationId: d['consultationId'] as String? ?? '',
      macroPlan: macro,
      macroModifications: modifications,             // ← nuevo
      dietGuidelines: List<String>.from(d['dietGuidelines'] ?? []),
      habits: List<String>.from(d['habits'] ?? []),
      goals: List<String>.from(d['goals'] ?? []),
      additionalNotes: d['additionalNotes'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate().toIso8601String()
          ?? DateTime.now().toIso8601String(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate().toIso8601String()
          ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'patientUid': patientUid,
        'nutriologistId': nutriologistId,
        'consultationId': consultationId,
        'macroPlan': macroPlan?.toJson(),
        'dietGuidelines': dietGuidelines,
        'habits': habits,
        'goals': goals,
        'additionalNotes': additionalNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  RecommendationEntity toEntity() => RecommendationEntity(
        id: id,
        patientId: patientId,
        patientUid: patientUid,
        nutriologistId: nutriologistId,
        consultationId: consultationId,
        macroPlan: macroPlan?.toEntity(),
        macroModifications: macroModifications,  // ← nuevo
        dietGuidelines: dietGuidelines,
        habits: habits,
        goals: goals,
        additionalNotes: additionalNotes,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );
}
