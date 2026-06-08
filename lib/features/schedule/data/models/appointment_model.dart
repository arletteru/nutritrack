// features/schedule/data/models/appointment_model.dart
//
// CAPA: Data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/appointment_entity.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@freezed
abstract class AppointmentModel with _$AppointmentModel {
  const AppointmentModel._();

  const factory AppointmentModel({
    required String id,
    required String patientId,
    required String nutriologistId,
    required String patientName,
    required String scheduledAt,   // ISO-8601
    @Default(60) int durationMinutes,
    required String statusStr,
    required String typeStr,
    String? notes,
    String? consultationId,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  // ── Firestore document → AppointmentModel ─────────────────────────────────
  factory AppointmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppointmentModel(
      id: doc.id,
      patientId: d['patientId'] as String,
      nutriologistId: d['nutriologistId'] as String,
      patientName: d['patientName'] as String? ?? '',
      scheduledAt: (d['scheduledAt'] as Timestamp).toDate().toIso8601String(),
      durationMinutes: d['durationMinutes'] as int? ?? 60,
      statusStr: d['status'] as String? ?? 'scheduled',
      typeStr: d['type'] as String? ?? 'firstConsult',
      notes: d['notes'] as String?,
      consultationId: d['consultationId'] as String?,
    );
  }

  // ── AppointmentModel → Firestore map ──────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'nutriologistId': nutriologistId,
        'patientName': patientName,
        'scheduledAt': Timestamp.fromDate(DateTime.parse(scheduledAt)),
        'durationMinutes': durationMinutes,
        'status': statusStr,
        'type': typeStr,
        'notes': notes,
        'consultationId': consultationId,
      };

  // ── AppointmentModel → domain AppointmentEntity ───────────────────────────
  AppointmentEntity toEntity() => AppointmentEntity(
        id: id,
        patientId: patientId,
        nutriologistId: nutriologistId,
        patientName: patientName,
        scheduledAt: DateTime.parse(scheduledAt),
        durationMinutes: durationMinutes,
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => AppointmentStatus.scheduled,
        ),
        type: AppointmentType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => AppointmentType.firstConsult,
        ),
        notes: notes,
        consultationId: consultationId,
      );
}
