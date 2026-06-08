import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/firebase_exception_mapper.dart';
import '../../domain/entities/consultation_entity.dart';

abstract class IConsultationDataSource {
  Future<String> createConsultation(Map<String, dynamic> data);
  Future<void> saveStep({required String consultationId, required int stepNumber, required Map<String, dynamic> data});
  Future<void> completeConsultation(String consultationId);
  Stream<List<Map<String, dynamic>>> watchPatientConsultations(String patientId);
  Future<Map<String, dynamic>?> getStep(String consultationId, int stepNumber);
  Stream<List<Map<String, dynamic>>> watchConsultationsByNutriologist({required String patientId,required String nutriologistId,});
}

class ConsultationFirestoreDataSource implements IConsultationDataSource {
  final FirebaseFirestore _db;
  ConsultationFirestoreDataSource({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> createConsultation(Map<String, dynamic> data) async {
    try {
      final ref = await _db.collection('consultations').add({
        ...data,
        'patientUid': data['patientUid'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) { throw mapFirebaseException(e); }
  }

  @override
  Future<void> saveStep({required String consultationId, required int stepNumber, required Map<String, dynamic> data}) async {
    try {
      final batch = _db.batch();
      final stepRef = _db.collection('consultations').doc(consultationId)
          .collection('steps').doc('step$stepNumber');
      batch.set(stepRef, {...data, 'stepNumber': stepNumber, 'isComplete': true,
          'savedAt': FieldValue.serverTimestamp()});
      batch.update(_db.collection('consultations').doc(consultationId), {
        'currentStep': stepNumber + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) { throw mapFirebaseException(e); }
  }

  @override
  Future<void> completeConsultation(String consultationId) async {
    try {
      await _db.collection('consultations').doc(consultationId).update({
        'status': ConsultationStatus.complete.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) { throw mapFirebaseException(e); }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchPatientConsultations(String patientUid) {
    if (patientUid.isEmpty) return Stream.value([]);
    return _db
        .collection('consultations')
        .where('patientUid', isEqualTo: patientUid)  // ← campo nuevo
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> watchConsultationsByNutriologist({
    required String patientId,
    required String nutriologistId,
  }) {
    if (patientId.isEmpty) return Stream.value([]);
    return _db
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .where('nutriologistId', isEqualTo: nutriologistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  @override
  Future<Map<String, dynamic>?> getStep(String consultationId, int stepNumber) async {
    try {
      final doc = await _db.collection('consultations').doc(consultationId)
          .collection('steps').doc('step$stepNumber').get();
      return doc.exists ? doc.data() : null;
    } catch (e) { throw mapFirebaseException(e); }
  }
}
