import 'package:nutritrack/features/daily_log/data/models/daily_log_model.dart';

import '../../domain/entities/daily_log_entity.dart';
import '../../domain/repositories/i_daily_log_repository.dart';
import '../datasources/daily_log_firestore_datasource.dart';

class DailyLogRepositoryImpl implements IDailyLogRepository {
  final IDailyLogDataSource _ds;
  const DailyLogRepositoryImpl(this._ds);

  @override
  Stream<DailyLogEntity?> watchTodayLog(String patientId) =>
      _ds.watchTodayLog(patientId).map((m) => m?.toEntity());

  @override
  Stream<List<DailyLogEntity>> watchRecentLogs(String patientId, {int days = 7}) =>
      _ds.watchRecentLogs(patientId, days: days).map((l) => l.map((m) => m.toEntity()).toList());

  @override
  Future<void> toggleTask({required String patientId, required String taskId, required bool completed}) =>
      _ds.toggleTask(patientId: patientId, taskId: taskId, completed: completed);

  @override
  Future<void> saveLog(DailyLogEntity log) {
    final model = DailyLogModel.fromEntity(log);
    return _ds.saveLog(log.patientId, model.toFirestore());
  }
}

class TasksRepositoryImpl implements ITasksRepository {
  final ITasksDataSource _ds;
  const TasksRepositoryImpl(this._ds);

  @override
  Stream<List<TaskEntity>> watchTasks(String patientId) =>
      _ds.watchTasks(patientId).map((l) => l.map((m) => m.toEntity()).toList());

  @override
  Future<void> createTask(String patientId, Map<String, dynamic> data) =>
      _ds.createTask(patientId, data);
}
