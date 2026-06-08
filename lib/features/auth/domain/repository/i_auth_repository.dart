import '../entities/user_entity.dart';

/// Contract that the Data layer must implement.
/// Domain knows nothing about Firebase — only this interface.
abstract class IAuthRepository {
  /// Sign in with email and password.
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  Future< UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  });

  /// Sign in via Google OAuth.
  Future<UserEntity> signInWithGoogle();

  /// Sign in via Apple OAuth (iOS / macOS only).
  Future<UserEntity> signInWithApple();

  /// Sign out the current user from all providers.
  Future<void> signOut();

  /// Returns the currently authenticated user, or null.
  Future<UserEntity?> getCurrentUser();

  /// Stream that emits a new [UserEntity] (or null) whenever auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Send a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email);

  /// Send an email-verification link to the current user.
  Future<void> sendEmailVerification();
}
