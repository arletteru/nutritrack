import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/schedule_providers.dart';

part 'schedule_notifier.g.dart';

@riverpod
class CreateAppointmentNotifier extends _$CreateAppointmentNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> create(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(appointmentsRepositoryProvider).createAppointment(data));
  }
}
