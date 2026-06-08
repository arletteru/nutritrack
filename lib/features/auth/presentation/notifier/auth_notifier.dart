import 'dart:async';
import 'package:nutritrack/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_use_cases.dart';

part 'auth_notifier.g.dart';


// ─── Login Notifier ───────────────────────────────────────────────────────────

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  AsyncValue<UserEntity?> build() {
    return const AsyncData(null);
  }

  Future<void> signIn({required String email, required String password}) async {

    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {

      final useCase = ref.read(
        signInWithEmailAndPasswordProvider,
      );

      return await useCase(
        SignInParams(email: email, password: password)
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(
        signInWithGoogleProvider,
      );
      return await useCase();
    });
  }

  Future<void> signInWithApple() async {
    if (state.isLoading) return;

    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {

      final useCase = ref.read(
        signInWithAppleProvider,
      );

      return await useCase();
    });
  }

  void reset() => state = const AsyncData(null);
}

// ─── Register Notifier ────────────────────────────────────────────────────────

@riverpod
class RegisterNotifier
    extends _$RegisterNotifier {

  @override
  AsyncValue<UserEntity?> build() {

    return const AsyncData(null);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    required bool acceptedTerms,

  }) async {

    if (!acceptedTerms) {
      state = AsyncError(
        Exception('Debes aceptar los Términos y Condiciones para continuar.',),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
 
    final result = await AsyncValue.guard(() async {
      final useCase = ref.read(signUpWithEmailAndPasswordProvider);
      return await useCase(
        SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
          role: role,
        ),
      );
    });
 
    if (!ref.mounted) return;
 
    state = result;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

// ─── Forgot Password Notifier ─────────────────────────────────────────────────

@riverpod
class ForgotPasswordNotifier extends _$ForgotPasswordNotifier {
  @override
  AsyncValue<String?> build() {
    return const AsyncData(null);
  }

  Future<void> sendResetEmail(String email,) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {

      final useCase = ref.read(sendPasswordResetEmailProvider,);
      await useCase(email);

      return email;
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

// ─── Sign Out ─────────────────────────────────────────────────────────────────
@riverpod
class SignOutNotifier extends _$SignOutNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(signOutUseCaseProvider);

      await useCase();
    });
  }
}