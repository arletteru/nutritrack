import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/patients_providers.dart';

part 'patients_notifier.g.dart';

@riverpod
class CreatePatientNotifier extends _$CreatePatientNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> create({
    required String fullName,
    required String email,
    required String expediente,
    required String nutriologistId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(createPatientUseCaseProvider).call(
              fullName: fullName,
              email: email,
              expediente: expediente,
              nutriologistId: nutriologistId,
            ));
  }
}
