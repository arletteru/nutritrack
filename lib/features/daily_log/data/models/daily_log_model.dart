// features/daily_log/data/models/daily_log_model.dart
//
// CAPA: Data

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/daily_log_entity.dart';

part 'daily_log_model.freezed.dart';
part 'daily_log_model.g.dart';

// ── TaskCompletionModel ────────────────────────────────────────────────────────
@freezed
abstract class TaskCompletionModel with _$TaskCompletionModel {
  const TaskCompletionModel._();

  const factory TaskCompletionModel({
    required String taskId,
    required bool completed,
    int? achievedValue,
    String? note,
  }) = _TaskCompletionModel;

  factory TaskCompletionModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCompletionModelFromJson(json);

  TaskCompletion toEntity() => TaskCompletion(
        taskId: taskId,
        completed: completed,
        achievedValue: achievedValue,
        note: note,
      );

  static TaskCompletionModel fromEntity(TaskCompletion e) =>
      TaskCompletionModel(
        taskId: e.taskId,
        completed: e.completed,
        achievedValue: e.achievedValue,
        note: e.note,
      );
}

// ── DailyLogModel ──────────────────────────────────────────────────────────────
@freezed
abstract class DailyLogModel with _$DailyLogModel {
  const DailyLogModel._();

  const factory DailyLogModel({
    required String patientId,
    required String date,           // dateKey: 'yyyy-MM-dd'
    @Default([]) List<TaskCompletionModel> taskCompletions,
    double? waterIntake,
    String? generalNotes,
    int? moodScore,
    @Default([]) List<String> meals,
  }) = _DailyLogModel;

  factory DailyLogModel.fromJson(Map<String, dynamic> json) =>
      _$DailyLogModelFromJson(json);

  // ── Firestore map → DailyLogModel ─────────────────────────────────────────
  factory DailyLogModel.fromFirestore(
      String patientId, String dateKey, Map<String, dynamic> data) {
    final completions = (data['taskCompletions'] as List<dynamic>? ?? [])
        .map((e) => TaskCompletionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DailyLogModel(
      patientId: patientId,
      date: dateKey,
      taskCompletions: completions,
      waterIntake: (data['waterIntake'] as num?)?.toDouble(),
      generalNotes: data['generalNotes'] as String?,
      moodScore: data['moodScore'] as int?,
    );
  }

  // ── DailyLogModel → Firestore map ─────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'date': date,
        'taskCompletions':
            taskCompletions.map((c) => c.toJson()).toList(),
        'waterIntake': waterIntake,
        'generalNotes': generalNotes,
        'moodScore': moodScore,
      };

  // ── DailyLogModel → domain DailyLogEntity ─────────────────────────────────
  DailyLogEntity toEntity() => DailyLogEntity(
        patientId: patientId,
        date: DateTime.parse(date),
        taskCompletions:
            taskCompletions.map((c) => c.toEntity()).toList(),
        waterIntake: waterIntake,
        generalNotes: generalNotes,
        moodScore: moodScore,
      );

  // ── DailyLogEntity → DailyLogModel (Inverso) ───────────────────────────────
  static DailyLogModel fromEntity(DailyLogEntity e) => DailyLogModel(
        patientId: e.patientId,
        date: e.dateKey, // Usa el get que calcula 'yyyy-MM-dd' en la entidad
        taskCompletions: e.taskCompletions
            .map((c) => TaskCompletionModel.fromEntity(c))
            .toList(),
        waterIntake: e.waterIntake,
        generalNotes: e.generalNotes,
        moodScore: e.moodScore,
        meals: e.meals,
      );
}


// ── TaskModel ─────────────────────────────────────────────────────────────────
@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String patientId,
    required String title,
    required String categoryStr,
    String? description,
    int? targetValue,
    String? unit,
    @Default('daily') String frequency,
    @Default(true) bool createdByNutrologist,
    required String createdAt, // ISO-8601
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  // ── TaskModel → domain TaskEntity ─────────────────────────────────────────
  TaskEntity toEntity() => TaskEntity(
        id: id,
        patientId: patientId,
        title: title,
        category: TaskCategory.values.firstWhere(
          (c) => c.name == categoryStr,
          orElse: () => TaskCategory.habit,
        ),
        description: description,
        targetValue: targetValue,
        unit: unit,
        frequency: frequency,
        createdByNutrologist: createdByNutrologist,
        createdAt: DateTime.parse(createdAt),
      );
}
