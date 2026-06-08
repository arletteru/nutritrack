// features/daily_log/domain/entities/daily_log_entity.dart
//
// CAPA: Domain

import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_log_entity.freezed.dart';

enum TaskCategory { nutrition, hydration, exercise, habit, supplement }

// ── TaskEntity ────────────────────────────────────────────────────────────────
@freezed
abstract class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    required String patientId,
    required String title,
    required TaskCategory category,
    String? description,
    int? targetValue,
    String? unit,
    @Default('daily') String frequency,
    @Default(true) bool createdByNutrologist,
    required DateTime createdAt,
  }) = _TaskEntity;
}

// ── TaskCompletion ─────────────────────────────────────────────────────────────
@freezed
abstract class TaskCompletion with _$TaskCompletion {
  const factory TaskCompletion({
    required String taskId,
    required bool completed,
    int? achievedValue,
    String? note,
  }) = _TaskCompletion;
}

// ── DailyLogEntity ─────────────────────────────────────────────────────────────
@freezed
abstract class DailyLogEntity with _$DailyLogEntity {
  const DailyLogEntity._();

  const factory DailyLogEntity({
    required String patientId,
    required DateTime date,
    @Default([]) List<TaskCompletion> taskCompletions,
    double? waterIntake,
    String? generalNotes,
    int? moodScore,
    @Default([]) List<String> meals,
  }) = _DailyLogEntity;

  // ── Computed ───────────────────────────────────────────────────────────────
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  int get completedCount =>
      taskCompletions.where((t) => t.completed).length;

  double get completionRate => taskCompletions.isEmpty
      ? 0.0
      : completedCount / taskCompletions.length;
  
  double completionRateOf(int totalTasks) =>
    totalTasks == 0 ? 0.0 : completedCount / totalTasks;
}
