import 'package:equatable/equatable.dart';

import '../../../../core/usecases/use_case.dart';
import '../entities/user_entity.dart';
import '../repository/i_auth_repository.dart';

// ─── Sign In ─────────────────────────────────────────────────────────────────

class SignInWithEmailAndPassword extends UseCase<UserEntity, SignInParams> {
  final IAuthRepository _repository;
  SignInWithEmailAndPassword(this._repository);

  @override
  Future<UserEntity> call(SignInParams params) =>
      _repository.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// ─── Sign Up ─────────────────────────────────────────────────────────────────

class SignUpWithEmailAndPassword
    extends UseCase<UserEntity, SignUpParams> {
  final IAuthRepository _repository;
  SignUpWithEmailAndPassword(this._repository);

  @override
  Future< UserEntity> call(SignUpParams params) =>
      _repository.signUpWithEmailAndPassword(
        email: params.email,
        password: params.password,
        displayName: params.displayName,
        role: params.role,
      );
    
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final UserRole role;
  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

// ─── Google Sign In ───────────────────────────────────────────────────────────

class SignInWithGoogle extends NoParamsUseCase<UserEntity> {
  final IAuthRepository _repository;
  SignInWithGoogle(this._repository);

  @override
  Future<UserEntity> call() =>
      _repository.signInWithGoogle();
}

// ─── Apple Sign In ────────────────────────────────────────────────────────────

class SignInWithApple extends NoParamsUseCase<UserEntity> {
  final IAuthRepository _repository;
  SignInWithApple(this._repository);

  @override
  Future<UserEntity> call() =>
      _repository.signInWithApple();
}

// ─── Sign Out ─────────────────────────────────────────────────────────────────

class SignOut extends NoParamsUseCase<void> {
  final IAuthRepository _repository;
  SignOut(this._repository);

  @override
  Future<void> call() =>
      _repository.signOut();
}

// ─── Get Current User ─────────────────────────────────────────────────────────

class GetCurrentUser extends NoParamsUseCase<UserEntity?> {
  final IAuthRepository _repository;
  GetCurrentUser(this._repository);

  @override
  Future<UserEntity?> call() => _repository.getCurrentUser();
}

// ─── Send Password Reset ──────────────────────────────────────────────────────

class SendPasswordResetEmail extends UseCase<void, String> {
  final IAuthRepository _repository;
  SendPasswordResetEmail(this._repository);

  @override
  Future<void> call(String email) =>
      _repository.sendPasswordResetEmail(email);
}
