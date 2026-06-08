// features/patients/data/models/patient_model.dart
//
// CAPA: Data — convierte documentos Firestore ↔ PatientEntity.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/patient_entity.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
abstract class PatientModel with _$PatientModel {
  const PatientModel._();

  const factory PatientModel({
    required String id,
    required String uid,
    required String nutriologistId,
    @Default('') String expediente,
    @Default('') String fullName,
    @Default('') String email,
    String? photoUrl,
    @Default('active') String statusStr,
    required String assignedAt,       // ISO-8601
    String? nextAppointment,          // ISO-8601 o null
  }) = _PatientModel;

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  // ── Firestore document → PatientModel ─────────────────────────────────────
  factory PatientModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PatientModel(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      nutriologistId: d['nutriologistId'] as String? ?? '',
      expediente: d['expediente'] as String? ?? '',
      fullName: d['fullName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      statusStr: d['status'] as String? ?? 'active',
      assignedAt: (d['assignedAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      nextAppointment:
          (d['nextAppointment'] as Timestamp?)?.toDate().toIso8601String(),
    );
  }

  // ── PatientModel → Firestore map ───────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'nutriologistId': nutriologistId,
        'expediente': expediente,
        'fullName': fullName,
        'email': email,
        'photoUrl': photoUrl,
        'status': statusStr,
        'assignedAt': FieldValue.serverTimestamp(),
        'nextAppointment': nextAppointment != null
            ? Timestamp.fromDate(DateTime.parse(nextAppointment!))
            : null,
      };

  // ── PatientModel → domain PatientEntity ───────────────────────────────────
  PatientEntity toEntity() => PatientEntity(
        id: id,
        uid: uid,
        nutriologistId: nutriologistId,
        expediente: expediente,
        fullName: fullName,
        email: email,
        photoUrl: photoUrl,
        status: PatientStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => PatientStatus.active,
        ),
        assignedAt: DateTime.parse(assignedAt),
        nextAppointment: nextAppointment != null
            ? DateTime.tryParse(nextAppointment!)
            : null,
      );
}
