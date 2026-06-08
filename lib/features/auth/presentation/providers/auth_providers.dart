import 'package:flutter/material.dart';
import 'package:nutritrack/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../../domain/usecases/auth_use_cases.dart';

part 'auth_providers.g.dart';

// Inyeccion de dependencias

// ─── Data Source ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
FirebaseAuthDataSource authDataSource(Ref ref) {
  return FirebaseAuthDataSource();
}

// ─── Repository ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
}

// ─── Use Cases ────────────────────────────────────────────────────────────────

@riverpod
SignInWithEmailAndPassword signInWithEmailAndPassword(
    Ref  ref) {
  return SignInWithEmailAndPassword(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpWithEmailAndPassword signUpWithEmailAndPassword(
    Ref  ref) {
  return SignUpWithEmailAndPassword(ref.watch(authRepositoryProvider));
} 

@riverpod
SignInWithGoogle signInWithGoogle(Ref  ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithApple signInWithApple(Ref  ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
}

@riverpod
SignOut signOutUseCase(Ref  ref) {
  return SignOut(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUser getCurrentUser(Ref  ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
}

@riverpod
SendPasswordResetEmail sendPasswordResetEmail(Ref  ref) {
  return SendPasswordResetEmail(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
Stream<UserEntity?> authStateChanges(Ref ref) {
  final repo = ref.read(authRepositoryProvider);
  debugPrint('🔐 usando repo: ${repo.hashCode}');
  return repo.authStateChanges.map((user) {
    debugPrint('🔐 authStateChanges emitió: ${user?.uid}');
    return user;
  });
}

