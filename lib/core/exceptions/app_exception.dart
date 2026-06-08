/// Excepciones tipadas de la app.
/// Se lanzan desde el Data layer y se capturan en los AsyncNotifiers.
/// La UI los muestra vía AsyncValue.error con .when(error: ...).
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// ── Auth ─────────────────────────────────────────────────────────────────────
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Correo o contraseña incorrectos.');
}

class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException()
      : super('Ya existe una cuenta con este correo.');
}

class GoogleSignInException extends AppException {
  const GoogleSignInException()
      : super('Hubo un error al iniciar sesión con Google.');
}

class InvalidEmailException extends AppException {
  const InvalidEmailException()
      : super('Cuenta de correo invalida.');
}

class UserNotFoundException extends AppException {
  const UserNotFoundException()
      : super('No existe una cuenta con este correo.');
}

class WeakPasswordException extends AppException {
  const WeakPasswordException()
      : super('La contraseña debe tener al menos 8 caracteres con mayúsculas y números.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('No tienes permiso para realizar esta acción.');
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException()
      : super('Demasiado intentos, vuelva a intentarlo más tarde.');
}

class UserDisabledException extends AppException {
  const UserDisabledException()
      : super('Usuario deshabilitado.');
}

class PatientNotRegisteredException extends AppException {
  const PatientNotRegisteredException()
      : super(
          'Tu correo no está registrado por el nutriólogo. '
          'Contacta a tu nutriólogo para que te dé de alta antes de crear tu cuenta.',
        );
}

// ── Network ───────────────────────────────────────────────────────────────────
class NetworkException extends AppException {
  const NetworkException() : super('Sin conexión a internet. Verifica tu red.');
}

// ── Firestore ─────────────────────────────────────────────────────────────────
class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException([String? detail])
      : super(detail ?? 'No se encontró el registro.');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('Acceso denegado. Contacta a tu nutriólogo.');
}

class SaveFailedException extends AppException {
  const SaveFailedException([String? detail])
      : super(detail ?? 'No se pudo guardar. Intenta de nuevo.');
}

// ── General ───────────────────────────────────────────────────────────────────
class UnexpectedException extends AppException {
  const UnexpectedException([String? detail])
      : super(detail ?? 'Ocurrió un error inesperado. Intenta de nuevo.');
}
