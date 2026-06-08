import '../entities/daily_log_entity.dart';

abstract class IDailyLogRepository {
  Stream<DailyLogEntity?> watchTodayLog(String patientId);
  Stream<List<DailyLogEntity>> watchRecentLogs(String patientId, {int days});
  Future<void> toggleTask({required String patientId, required String taskId, required bool completed});
  Future<void> saveLog(DailyLogEntity log);
}

abstract class ITasksRepository {
  Stream<List<TaskEntity>> watchTasks(String patientId);
  Future<void> createTask(String patientId, Map<String, dynamic> data);
}
