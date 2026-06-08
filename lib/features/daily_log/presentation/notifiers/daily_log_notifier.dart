import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/daily_log_providers.dart';

part 'daily_log_notifier.g.dart';

@riverpod
class ToggleTaskNotifier extends _$ToggleTaskNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> toggle({
    required String patientId,
    required String taskId,
    required bool completed,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(dailyLogRepositoryProvider).toggleTask(
              patientId: patientId,
              taskId: taskId,
              completed: completed,
            ));
  }
}
