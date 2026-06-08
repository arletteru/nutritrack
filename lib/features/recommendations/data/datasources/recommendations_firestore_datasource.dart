import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/exceptions/firebase_exception_mapper.dart';
import '../models/recommendation_model.dart';

abstract class IRecommendationsDataSource {
  Stream<RecommendationModel?> watchLatestForPatient(String patientId);
  Future<void> saveRecommendation(Map<String, dynamic> data);
}

class RecommendationsFirestoreDataSource implements IRecommendationsDataSource {
  final FirebaseFirestore _db;
  RecommendationsFirestoreDataSource({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  // En RecommendationsFirestoreDataSource.watchLatestForPatient
Stream<RecommendationModel?> watchLatestForPatient(String patientUid) {
  debugPrint('🔥 watchLatestForPatient — patientUid: "$patientUid"');
  if (patientUid.isEmpty) return Stream.value(null);
  return _db.collection('recommendations')
      .where('patientUid', isEqualTo: patientUid)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .snapshots()
      .map((s) {
        debugPrint('🔥 docs encontrados: ${s.docs.length}');
        if (s.docs.isNotEmpty) {
          debugPrint('🔥 doc patientUid: ${s.docs.first.data()['patientUid']}');
        }
        return s.docs.isEmpty ? null : RecommendationModel.fromFirestore(s.docs.first);
      });
}
              
  @override
  Future<void> saveRecommendation(Map<String, dynamic> data) async {
    try {
      await _db.collection('recommendations').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) { throw mapFirebaseException(e); }
  }
}
