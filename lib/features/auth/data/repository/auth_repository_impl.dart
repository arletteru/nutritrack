
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implements [IAuthRepository] using [IAuthDataSource].
/// Catches [FirebaseAuthException] and maps to domain [Failure]s.
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future< UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _execute(() => _dataSource.signInWithEmailAndPassword(email, password));

  @override
  Future< UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) =>
      _execute(() =>
          _dataSource.signUpWithEmailAndPassword(email, password, displayName, role));

  @override
  Future< UserEntity> signInWithGoogle() =>
      _execute(_dataSource.signInWithGoogle);

  @override
  Future<UserEntity> signInWithApple() =>
      _execute(_dataSource.signInWithApple);

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } catch (_) {
      throw const UnexpectedException();
    }
  }

  @override
  Future< UserEntity?> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return user?.toEntity();
    } catch (_) {
      throw const UnexpectedException();
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _dataSource.authStateChanges.map((m) => m?.toEntity());

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } catch (_) {
      throw const UnexpectedException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _dataSource.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } catch (_) {
      throw const UnexpectedException();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Generic wrapper that executes a datasource call returning [UserModel]
  /// and maps exceptions to [Exceptions].
  Future<UserEntity> _execute(Future<dynamic> Function() call) async {
    try {
      final model = await call();
      return model.toEntity() as UserEntity;
    } on AppException {
      rethrow; // ← deja pasar el AppException del datasource tal cual
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } on Exception catch (e) {
      if (e.toString().contains('aborted')) {
        throw const GoogleSignInException();
      }
      throw const UnexpectedException();
    } catch (_) {
      throw const UnexpectedException();
    }
  }

  /// Maps a [FirebaseAuthException] code → domain [Failure].
  Exception _mapException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'user-disabled':
        return const UserDisabledException();
      case 'network-request-failed':
        return const NetworkException();
      default:
        return UnexpectedException(e.message ?? 'Error inesperado.');
    }
  }
}
