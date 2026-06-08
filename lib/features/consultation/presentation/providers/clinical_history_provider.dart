// Lee pasos 2 (Antropometría) y 3 (Bioquímicos) de cada consulta completada.
// Usado por ClinicalRecordPage (nutriólogo) y WeightProgressCard (paciente).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clinical_history_provider.g.dart';

// ── Modelo con datos de ambos pasos ──────────────────────────────────────────
class ClinicalEntry {
  const ClinicalEntry({
    required this.date,
    required this.consultationId,
    this.weight,
    this.imc,
    this.height,
    this.waist,
    this.hip,
    this.glucose,
    this.triglycerides,
    this.totalCholesterol,
    this.hdl,
    this.ldl,
    this.hba1c,
    this.hemoglobin,
  });

  final DateTime date;
  final String consultationId;

  // Paso 2 — Antropometría
  final double? weight;
  final double? imc;
  final double? height;
  final double? waist;
  final double? hip;

  // Paso 3 — Bioquímicos
  final double? glucose;
  final double? triglycerides;
  final double? totalCholesterol;
  final double? hdl;
  final double? ldl;
  final double? hba1c;
  final double? hemoglobin;
}

double? _parseNum(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}

// ── Provider para el nutriólogo (usa patientId doc) ──────────────────────────
@riverpod
Future<List<ClinicalEntry>> watchClinicalHistory(
  Ref ref, {
  required String patientUid,
  required String nutriologistId,
  String? patientDocId,
}) async {
  final db = FirebaseFirestore.instance;

  // Busca por patientUid si existe, sino por patientId+nutriologistId
  QuerySnapshot<Map<String, dynamic>> snap;
  if (patientUid.isNotEmpty) {
    snap = await db
        .collection('consultations')
        .where('patientUid', isEqualTo: patientUid)
        .where('status', isEqualTo: 'complete')
        .orderBy('createdAt')
        .get();
  } else if (patientDocId != null && patientDocId.isNotEmpty) {
    snap = await db
        .collection('consultations')
        .where('patientId', isEqualTo: patientDocId)
        .where('nutriologistId', isEqualTo: nutriologistId)
        .where('status', isEqualTo: 'complete')
        .orderBy('createdAt')
        .get();
  } else {
    return [];
  }

  if (snap.docs.isEmpty) return [];

  final futures = snap.docs.map((doc) async {
    try {
      final stepsCol = db.collection('consultations').doc(doc.id).collection('steps');
      final step2Future = stepsCol.doc('step2').get();
      final step3Future = stepsCol.doc('step3').get();
      final results = await Future.wait([step2Future, step3Future]);

      final s2 = results[0].data();
      final s3 = results[1].data();

      final createdAt = doc.data()['createdAt'];
      final date = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now();

      return ClinicalEntry(
        date: date,
        consultationId: doc.id,
        // Paso 2
        weight: _parseNum(s2?['currentWeight']),
        imc: _parseNum(s2?['imc']),
        height: _parseNum(s2?['height']),
        waist: _parseNum(s2?['waist']),
        hip: _parseNum(s2?['hip']),
        // Paso 3
        glucose: _parseNum(s3?['glucose']),
        triglycerides: _parseNum(s3?['triglycerides']),
        totalCholesterol: _parseNum(s3?['totalCholesterol']),
        hdl: _parseNum(s3?['hdl']),
        ldl: _parseNum(s3?['ldl']),
        hba1c: _parseNum(s3?['hba1c']),
        hemoglobin: _parseNum(s3?['hemoglobin']),
      );
    } catch (_) {
      return null;
    }
  });

  final results = await Future.wait(futures);
  return results.whereType<ClinicalEntry>().toList();
}
