// features/recommendations/presentation/notifiers/generate_plan_notifier.dart
//
// Crea el documento en recommendations/ y las tasks básicas
// a partir de los datos del paso 6 del wizard.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generate_plan_notifier.g.dart';

@riverpod
class GeneratePlanNotifier extends _$GeneratePlanNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> generate({
    required String patientId,      // doc ID de patients/
    required String patientUid,     // uid de Firebase Auth
    required String nutriologistId,
    required String consultationId,
    required Map<String, dynamic> step6Data,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // ── 1. Extraer datos del paso 6 ──────────────────────────────────────
      final recommendations =
          List<String>.from(step6Data['generalRecommendations'] ?? []);
      final macros =
          List<dynamic>.from(step6Data['macroModifications'] ?? []);
      final treatmentObjectives =
          step6Data['treatmentObjectives'] as String? ?? '';
      final pesNutritionProblem =
          step6Data['pesNutritionProblem'] as String? ?? '';

      // ── 2. Crear recommendation/ ──────────────────────────────────────────
      final recRef = db.collection('recommendations').doc();
      batch.set(recRef, {
        'patientId': patientId,
        'patientUid': patientUid,
        'nutriologistId': nutriologistId,
        'consultationId': consultationId,
        'dietGuidelines': recommendations,
        'habits': _extractHabits(recommendations),
        'goals': treatmentObjectives.isNotEmpty
            ? [treatmentObjectives]
            : [],
        'macroPlan': _buildMacroPlan(macros),
        'additionalNotes': pesNutritionProblem,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ── 3. Crear tasks/ basadas en las recomendaciones ────────────────────
      // Solo crea tasks si el paciente ya tiene uid (está registrado)
      if (patientUid.isNotEmpty) {
        // limpia tasks anteriores antes de crear las nuevas
        final existingTasks = await db
            .collection('tasks')
            .doc(patientUid)
            .collection('items')
            .get();
        for (final doc in existingTasks.docs) {
          batch.delete(doc.reference);
        }
        
        final tasksCollection = db
            .collection('tasks')
            .doc(patientUid)
            .collection('items');

        // Task de hidratación — siempre se agrega
        final waterTask = tasksCollection.doc();
        batch.set(waterTask, {
          'title': 'Consumo de agua diario',
          'category': 'hydration',
          'description': 'Mantener hidratación según indicación nutricional',
          'targetValue': 8,
          'unit': 'vasos',
          'frequency': 'daily',
          'createdByNutrologist': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Tasks desde las recomendaciones generales
        for (final rec in recommendations.take(4)) {
          // Máximo 4 tareas automáticas para no saturar
          if (rec.trim().isEmpty) continue;
          final taskRef = tasksCollection.doc();
          batch.set(taskRef, {
            'title': rec.trim(),
            'category': _inferCategory(rec),
            'description': null,
            'frequency': 'daily',
            'createdByNutrologist': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      debugPrint('✅ Plan nutricional generado correctamente');
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extrae hábitos de las recomendaciones (palabras clave)
  List<String> _extractHabits(List<String> recommendations) {
    return recommendations
        .where((r) =>
            r.toLowerCase().contains('actividad') ||
            r.toLowerCase().contains('ejercicio') ||
            r.toLowerCase().contains('caminar') ||
            r.toLowerCase().contains('dormir') ||
            r.toLowerCase().contains('hábito'))
        .toList();
  }

  /// Infiere la categoría de la task según el texto
  String _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('agua') || lower.contains('líquido') ||
        lower.contains('hidrat')) return 'hydration';
    if (lower.contains('ejercicio') || lower.contains('actividad') ||
        lower.contains('caminar') || lower.contains('deporte')) return 'exercise';
    if (lower.contains('vitamina') || lower.contains('suplemento') ||
        lower.contains('omega') || lower.contains('probiótico')) return 'supplement';
    if (lower.contains('comer') || lower.contains('consumir') ||
        lower.contains('evitar') || lower.contains('incluir')) return 'nutrition';
    return 'habit';
  }

  /// Construye el map de macros para Firestore
  Map<String, dynamic>? _buildMacroPlan(List<dynamic> macros) {
    if (macros.isEmpty) return null;
    // Guarda la lista completa de modificaciones como está
    return {
      'modifications': macros,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
