// features/schedule/domain/entities/appointment_entity.dart
//
// CAPA: Domain — sin dependencias externas.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_entity.freezed.dart';

enum AppointmentStatus { scheduled, confirmed, completed, cancelled, noShow }
enum AppointmentType   { firstConsult, followUp, emergency }

@freezed
abstract class AppointmentEntity with _$AppointmentEntity {
  const AppointmentEntity._();

  const factory AppointmentEntity({
    required String id,
    required String patientId,
    required String nutriologistId,
    required String patientName,
    required DateTime scheduledAt,
    @Default(60) int durationMinutes,
    required AppointmentStatus status,
    required AppointmentType type,
    String? notes,
    String? consultationId,
  }) = _AppointmentEntity;

  // ── Computed ───────────────────────────────────────────────────────────────
  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) &&
      status != AppointmentStatus.cancelled;

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isCancellable =>
      status == AppointmentStatus.scheduled ||
      status == AppointmentStatus.confirmed;
}
