import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/firebase_exception_mapper.dart';
import '../models/appointment_model.dart';

abstract class IAppointmentsDataSource {
  Stream<List<AppointmentModel>> watchUpcomingForNutrologist(String nutriologistId);
  Stream<List<AppointmentModel>> watchTodayForNutrologist(String nutriologistId);
  Stream<AppointmentModel?> watchNextForPatient(String patientId);
  Future<void> createAppointment(Map<String, dynamic> data);
  Future<void> updateStatus(String id, String statusStr);
}

class AppointmentsFirestoreDataSource implements IAppointmentsDataSource {
  final FirebaseFirestore _db;
  AppointmentsFirestoreDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<AppointmentModel>> watchUpcomingForNutrologist(String nutriologistId) =>
      _db.collection('appointments')
          .where('nutriologistId', isEqualTo: nutriologistId)
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .orderBy('scheduledAt').limit(30).snapshots()
          .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());

  @override
  Stream<List<AppointmentModel>> watchTodayForNutrologist(String nutriologistId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _db.collection('appointments')
        .where('nutriologistId', isEqualTo: nutriologistId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('scheduledAt').snapshots()
        .map((s) => s.docs.map(AppointmentModel.fromFirestore).toList());
  }

  @override
  Stream<AppointmentModel?> watchNextForPatient(String patientUid) {
    if (patientUid.isEmpty) return Stream.value(null);
    return _db
        .collection('appointments')
        .where('patientUid', isEqualTo: patientUid)  // ← campo correcto
        .where('scheduledAt', isGreaterThanOrEqualTo: 
            Timestamp.fromDate(DateTime.now()))
        .where('status', whereIn: ['scheduled', 'confirmed'])
        .orderBy('scheduledAt')
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : AppointmentModel.fromFirestore(s.docs.first));
  }
  
  @override
  Future<void> createAppointment(Map<String, dynamic> data) async {
    try {
      await _db.collection('appointments').add({...data, 'createdAt': FieldValue.serverTimestamp()});
    } catch (e) { throw mapFirebaseException(e); }
  }

  @override
  Future<void> updateStatus(String id, String statusStr) async {
    try {
      await _db.collection('appointments').doc(id).update({
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) { throw mapFirebaseException(e); }
  }
}
