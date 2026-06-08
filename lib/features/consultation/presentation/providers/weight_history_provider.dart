// Lee el paso 2 (Antropometría) de cada consulta completada del paciente
// para construir la serie de datos del gráfico de peso.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_history_provider.g.dart';

// ── Modelo simple para cada punto del gráfico ─────────────────────────────────
class WeightEntry {
  const WeightEntry({
    required this.date,
    required this.weight,
    this.imc,
    this.consultationId,
  });

  final DateTime date;
  final double weight;
  final double? imc;
  final String? consultationId;
}

// ── Provider ──────────────────────────────────────────────────────────────────
@riverpod
Future<List<WeightEntry>> watchWeightHistory(
  Ref ref,
  String patientUid,
) async {
  if (patientUid.isEmpty) return [];

  final db = FirebaseFirestore.instance;

  // 1. Obtiene consultas completadas del paciente ordenadas por fecha
  final consultationsSnap = await db
      .collection('consultations')
      .where('patientUid', isEqualTo: patientUid)
      .where('status', isEqualTo: 'complete')
      .orderBy('createdAt')
      .get();

  if (consultationsSnap.docs.isEmpty) return [];

  // 2. Por cada consulta, lee el paso 2 en paralelo
  final futures = consultationsSnap.docs.map((doc) async {
    try {
      final step2 = await db
          .collection('consultations')
          .doc(doc.id)
          .collection('steps')
          .doc('step2')
          .get();

      if (!step2.exists) return null;
      final data = step2.data()!;

      // El peso puede venir como double o String dependiendo del TextFormField
      final rawWeight = data['currentWeight'];
      final weight = rawWeight is double
          ? rawWeight
          : rawWeight is int
              ? rawWeight.toDouble()
              : double.tryParse(rawWeight?.toString() ?? '');

      if (weight == null || weight <= 0) return null;

      // Fecha de la consulta
      final createdAt = doc.data()['createdAt'];
      final date = createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now();

      // IMC opcional
      final rawImc = data['imc'];
      final imc = rawImc is double
          ? rawImc
          : rawImc is int
              ? rawImc.toDouble()
              : double.tryParse(rawImc?.toString() ?? '');

      return WeightEntry(
        date: date,
        weight: weight,
        imc: imc,
        consultationId: doc.id,
      );
    } catch (_) {
      return null;
    }
  });

  final results = await Future.wait(futures);
  return results.whereType<WeightEntry>().toList();
}

// ── Provider para la meta de peso (desde recommendations) ─────────────────────
@riverpod
Future<double?> watchWeightGoal(
  Ref ref,
  String patientUid,
) async {
  if (patientUid.isEmpty) return null;

  final snap = await FirebaseFirestore.instance
      .collection('recommendations')
      .where('patientUid', isEqualTo: patientUid)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return null;

  // Busca en goals un texto con número de peso (ej. "73 kg", "llegar a 70kg")
  final goals = List<String>.from(snap.docs.first.data()['goals'] ?? []);
  for (final goal in goals) {
    final match = RegExp(r'(\d{2,3}(?:\.\d)?)\s*kg').firstMatch(goal);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
  }
  return null;
}
