import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/daily_log_firestore_datasource.dart';
import '../../data/repositories/daily_log_repository_impl.dart';
import '../../domain/entities/daily_log_entity.dart';
import '../../domain/repositories/i_daily_log_repository.dart';
import '../../domain/usecases/daily_log_use_cases.dart';

part 'daily_log_providers.g.dart';

@Riverpod(keepAlive: true)
IDailyLogDataSource dailyLogDataSource(Ref ref) =>
    DailyLogFirestoreDataSource();

@Riverpod(keepAlive: true)
ITasksDataSource tasksDataSource(Ref ref) =>
    TasksFirestoreDataSource();

@Riverpod(keepAlive: true)
IDailyLogRepository dailyLogRepository(Ref ref) =>
    DailyLogRepositoryImpl(ref.watch(dailyLogDataSourceProvider));

@Riverpod(keepAlive: true)
ITasksRepository tasksRepository(Ref ref) =>
    TasksRepositoryImpl(ref.watch(tasksDataSourceProvider));

@riverpod
Stream<DailyLogEntity?> watchTodayLog(Ref ref, String patientId) =>
    WatchTodayLogUseCase(ref.watch(dailyLogRepositoryProvider)).call(patientId);

@riverpod
Stream<List<DailyLogEntity>> watchRecentLogs(Ref ref, String patientId) =>
    WatchRecentLogsUseCase(ref.watch(dailyLogRepositoryProvider)).call(patientId);

@riverpod
Stream<List<TaskEntity>> watchTasks(Ref ref, String patientId) =>
    WatchTasksUseCase(ref.watch(tasksRepositoryProvider)).call(patientId);
