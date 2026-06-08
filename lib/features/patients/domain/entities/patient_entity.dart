// features/patients/domain/entities/patient_entity.dart
//
// CAPA: Domain — sin dependencias externas.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_entity.freezed.dart';

enum PatientStatus { active, inactive, archived }

@freezed
abstract class PatientEntity with _$PatientEntity {
  const PatientEntity._();

  const factory PatientEntity({
    required String id,
    required String uid,
    required String nutriologistId,
    required String expediente,
    required String fullName,
    required String email,
    String? photoUrl,
    @Default(PatientStatus.active) PatientStatus status,
    required DateTime assignedAt,
    DateTime? nextAppointment,
  }) = _PatientEntity;

  // ── Computed ───────────────────────────────────────────────────────────────
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasUpcomingAppointment => nextAppointment != null &&
      nextAppointment!.isAfter(DateTime.now());
}
