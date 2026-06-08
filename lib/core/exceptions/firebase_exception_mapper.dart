import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

/// Convierte excepciones de Firebase en [AppException]s del dominio.
/// Uso: en los datasources, dentro de try/catch.
AppException mapFirebaseException(Object e) {
  if (e is AppException) return e;
  if (e is FirebaseAuthException) return _mapAuth(e);
  if (e is FirebaseException) return _mapFirestore(e);
  return const UnexpectedException();
}

AppException _mapAuth(FirebaseAuthException e) {
  return switch (e.code) {
    'user-not-found' => const UserNotFoundException(),
    'wrong-password' || 'invalid-credential' => const InvalidCredentialsException(),
    'email-already-in-use' => const EmailAlreadyInUseException(),
    'weak-password' => const WeakPasswordException(),
    'network-request-failed' => const NetworkException(),
    'permission-denied' => const PermissionDeniedException(),
    _ => UnexpectedException(e.message),
  };
}

AppException _mapFirestore(FirebaseException e) {
  return switch (e.code) {
    'not-found' => const DocumentNotFoundException(),
    'permission-denied' => const PermissionDeniedException(),
    'unavailable' => const NetworkException(),
    'cancelled' => const UnexpectedException('Operación cancelada.'),
    _ => UnexpectedException(e.message),
  };
}
