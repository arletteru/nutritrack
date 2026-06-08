import '../entities/daily_log_entity.dart';
import '../repositories/i_daily_log_repository.dart';

class WatchTodayLogUseCase {
  final IDailyLogRepository _repo;
  const WatchTodayLogUseCase(this._repo);
  Stream<DailyLogEntity?> call(String patientId) => _repo.watchTodayLog(patientId);
}

class WatchRecentLogsUseCase {
  final IDailyLogRepository _repo;
  const WatchRecentLogsUseCase(this._repo);
  Stream<List<DailyLogEntity>> call(String patientId, {int days = 7}) =>
      _repo.watchRecentLogs(patientId, days: days);
}

class ToggleTaskUseCase {
  final IDailyLogRepository _repo;
  const ToggleTaskUseCase(this._repo);
  Future<void> call({required String patientId, required String taskId, required bool completed}) =>
      _repo.toggleTask(patientId: patientId, taskId: taskId, completed: completed);
}

class WatchTasksUseCase {
  final ITasksRepository _repo;
  const WatchTasksUseCase(this._repo);
  Stream<List<TaskEntity>> call(String patientId) => _repo.watchTasks(patientId);
}
