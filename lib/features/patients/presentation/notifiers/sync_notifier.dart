// features/patients/presentation/notifiers/sync_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/patients_providers.dart';

part 'sync_notifier.g.dart';

@riverpod
class SyncPatientHistoryNotifier extends _$SyncPatientHistoryNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> sync({
    required String patientDocId,
    required String patientUid,
    required String nutriologistId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(patientsRepositoryProvider).syncPatientHistory(
              patientDocId: patientDocId,
              patientUid: patientUid,
              nutriologistId: nutriologistId,
            ));
  }
}
