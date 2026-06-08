import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/exceptions/firebase_exception_mapper.dart';
import '../models/patient_model.dart';

abstract class IPatientsDataSource {
  Stream<List<PatientModel>> watchPatients(String nutriologistId);
  Future<PatientModel?> getPatient(String patientId);
  Future<void> createPatient(Map<String, dynamic> data);
  Future<void> updatePatient(String patientId, Map<String, dynamic> data);
  Future<void> syncPatientHistory({
    required String patientDocId,
    required String patientUid,
    required String nutriologistId,
  });
}

class PatientsFirestoreDataSource implements IPatientsDataSource {
  final FirebaseFirestore _db;
  PatientsFirestoreDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<PatientModel>> watchPatients(String nutriologistId) {
    return _db
        .collection('patients')
        .where('nutriologistId', isEqualTo: nutriologistId)
        .where('status', isEqualTo: 'active')
        .orderBy('fullName')
        .snapshots()
        .map((s) => s.docs.map(PatientModel.fromFirestore).toList());
  }

  @override
  Future<PatientModel?> getPatient(String patientId) async {
    try {
      final doc = await _db.collection('patients').doc(patientId).get();
      if (!doc.exists) return null;
      return PatientModel.fromFirestore(doc);
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> createPatient(Map<String, dynamic> data) async {
    try {
      await _db.collection('patients').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      await _db.collection('patients').doc(patientId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<void> syncPatientHistory({
    required String patientDocId,
    required String patientUid,
    required String nutriologistId,
  }) async {
    try {
      debugPrint('syncPatientHistory START — patientDocId: $patientDocId, patientUid: $patientUid');

      // El nutriólogo tiene permiso para leer y escribir sus propias consultas
      final consultations = await _db
          .collection('consultations')
          .where('patientId', isEqualTo: patientDocId)
          .where('nutriologistId', isEqualTo: nutriologistId)
          .get();

      debugPrint('consultations encontradas: ${consultations.docs.length}');

      final appointments = await _db
          .collection('appointments')
          .where('patientId', isEqualTo: patientDocId)
          .where('nutriologistId', isEqualTo: nutriologistId)
          .get();

      debugPrint('appointments encontradas: ${appointments.docs.length}');

      final recommendations = await _db
          .collection('recommendations')
          .where('patientId', isEqualTo: patientDocId)
          .where('nutriologistId', isEqualTo: nutriologistId)
          .get();


      if (consultations.docs.isEmpty && appointments.docs.isEmpty) {
        debugPrint('nada que sincronizar');
        return;
      }

      final batch = _db.batch();

      for (final doc in consultations.docs) {
        // Solo actualizar si patientUid está vacío para no sobreescribir
        if ((doc.data()['patientUid'] as String?) == '') {
          batch.update(doc.reference, {'patientUid': patientUid});
        }
      }

      for (final doc in appointments.docs) {
        if ((doc.data()['patientUid'] as String?) == '') {
          batch.update(doc.reference, {'patientUid': patientUid});
        }
      }

      for (final rec in recommendations.docs) {
            // Actualiza patientUid
            batch.update(rec.reference, {'patientUid': patientUid});
            
            // Crea tasks si no existen aún 
            // Obtiene tasks existentes SIN limit(1) para poder borrarlas todas
            final tasksSnap = await _db
                .collection('tasks')
                .doc(patientUid)
                .collection('items')
                .get();

            // Borra todas las tasks viejas
            for (final task in tasksSnap.docs) {
              batch.delete(task.reference);
            }

            // Crea las nuevas siempre — sin el if
            final guidelines = List<String>.from(rec.data()['dietGuidelines'] ?? []);
            final tasksRef = _db.collection('tasks').doc(patientUid).collection('items');

            batch.set(tasksRef.doc(), {
              'title': 'Consumo de agua diario',
              'category': 'hydration',
              'frequency': 'daily',
              'createdByNutrologist': true,
              'createdAt': FieldValue.serverTimestamp(),
            });

            for (final g in guidelines.take(4)) {
              if (g.trim().isEmpty) continue;
              batch.set(tasksRef.doc(), {
                'title': g.trim(),
                'category': 'habit',
                'frequency': 'daily',
                'createdByNutrologist': true,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }

      await batch.commit();
      debugPrint('syncPatientHistory COMPLETO');
    } catch (e) {
      debugPrint('syncPatientHistory error: $e');
      throw mapFirebaseException(e);
    }
  }
}
