import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/firebase_exception_mapper.dart';
import '../models/daily_log_model.dart';

abstract class IDailyLogDataSource {
  Stream<DailyLogModel?> watchTodayLog(String patientId);
  Stream<List<DailyLogModel>> watchRecentLogs(String patientId, {int days});
  Future<void> toggleTask({required String patientId, required String taskId, required bool completed});
  Future<void> saveLog(String patientId, Map<String, dynamic> data);
}

abstract class ITasksDataSource {
  Stream<List<TaskModel>> watchTasks(String patientId);
  Future<void> createTask(String patientId, Map<String, dynamic> data);
  Future<void> deleteAllTasks(String patientId);
}

class DailyLogFirestoreDataSource implements IDailyLogDataSource {
  final FirebaseFirestore _db;
  DailyLogFirestoreDataSource({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Stream<DailyLogModel?> watchTodayLog(String patientId) {
    final today = _dateKey(DateTime.now());
    return _db.collection('daily_logs').doc(patientId)
        .collection('entries').doc(today).snapshots()
        .map((snap) => snap.exists
            ? DailyLogModel.fromFirestore(patientId, today, snap.data()!)
            : null);
  }

  @override
  Stream<List<DailyLogModel>> watchRecentLogs(String patientId, {int days = 7}) {
    final cutoff = _dateKey(DateTime.now().subtract(Duration(days: days)));
    return _db.collection('daily_logs').doc(patientId)
        .collection('entries')
        .where('date', isGreaterThanOrEqualTo: cutoff)
        .orderBy('date', descending: true).snapshots()
        .map((s) => s.docs.map((d) =>
            DailyLogModel.fromFirestore(patientId, d.id, d.data())).toList());
  }

  @override
  Future<void> toggleTask({required String patientId, required String taskId, required bool completed}) async {
    try {
      final today = _dateKey(DateTime.now());
      final ref = _db.collection('daily_logs').doc(patientId).collection('entries').doc(today);
      final snap = await ref.get();
      List<dynamic> completions = snap.exists
          ? List<dynamic>.from(snap.data()?['taskCompletions'] ?? [])
          : [];
      final idx = completions.indexWhere((c) => c['taskId'] == taskId);
      if (idx >= 0) {
        completions[idx]['completed'] = completed;
      } else {
        completions.add({'taskId': taskId, 'completed': completed});
      }
      await ref.set({'date': today, 'taskCompletions': completions,
          'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) { throw mapFirebaseException(e); }
  }

  @override
  Future<void> saveLog(String patientId, Map<String, dynamic> data) async {
    try {
      final today = _dateKey(DateTime.now());
      await _db.collection('daily_logs').doc(patientId).collection('entries').doc(today)
          .set({...data, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) { throw mapFirebaseException(e); }
  }
}

class TasksFirestoreDataSource implements ITasksDataSource {
  final FirebaseFirestore _db;
  TasksFirestoreDataSource({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<TaskModel>> watchTasks(String patientId) =>
      _db.collection('tasks').doc(patientId).collection('items')
          .orderBy('createdAt').snapshots()
          .map((s) => s.docs.map((d) {
            final data = d.data();
            return TaskModel.fromJson({
              'id': d.id,
              'patientId': patientId,
              'title': data['title'] as String? ?? '',
              'categoryStr': data['category'] as String? ?? 'habit',
              'description': data['description'] as String?,
              'targetValue': data['targetValue'] as int?,
              'unit': data['unit'] as String?,
              'frequency': data['frequency'] as String? ?? 'daily',
              'createdByNutrologist': data['createdByNutrologist'] as bool? ?? true,
              'createdAt': (data['createdAt'] as Timestamp?)
                      ?.toDate().toIso8601String() ??
                  DateTime.now().toIso8601String(),
            });
          }).toList());

  @override
  Future<void> createTask(String patientId, Map<String, dynamic> data) async {
    await _db.collection('tasks').doc(patientId).collection('items')
        .add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> deleteAllTasks(String patientId) async {
    final snap = await _db
        .collection('tasks')
        .doc(patientId)
        .collection('items')
        .get();
    
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
