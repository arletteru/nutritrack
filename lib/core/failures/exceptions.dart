/// Base class for all application exceptions.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}
// ─── Auth Failures ───────────────────────────────────────────────────────────

class NetworkException extends AppException {

  const NetworkException() : super(
          'Sin conexión a internet.',
        );
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException(
      [super.message = 'Correo o contraseña incorrectos.']);
}

class UserNotFoundException extends AppException {
  const UserNotFoundException(
      [super.message = 'No existe una cuenta con este correo.']);
}

class EmailAlreadyInUseException extends AppException{
  const EmailAlreadyInUseException(
      [super.message = 'Ya existe una cuenta con este correo electrónico.']);
}

class WeakPasswordException extends AppException {
  const WeakPasswordException(
      [super.message =
          'La contraseña es muy débil. Usa al menos 8 caracteres, mayúsculas y un número.']);
}

class InvalidEmailException extends AppException {
  const InvalidEmailException(
      [super.message = 'El formato del correo electrónico no es válido.']);
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException(
      [super.message =
          'Demasiados intentos. Por favor espera un momento e intenta de nuevo.']);
}

class UserDisabledException extends AppException {
  const UserDisabledException(
      [super.message = 'Tu cuenta ha sido deshabilitada. Contacta soporte.']);
}

class GoogleSignInException extends AppException {
  const GoogleSignInException(
      [super.message = 'No se pudo iniciar sesión con Google.']);
}

class AppleSignInException extends AppException {
  const AppleSignInException(
      [super.message = 'No se pudo iniciar sesión con Apple.']);
}

class UnexpectedException extends AppException {
  const UnexpectedException(
      [super.message = 'Ocurrió un error inesperado. Intenta de nuevo.']);
}

class SignOutException extends AppException {
  const SignOutException([super.message = 'Error al cerrar sesión.']);
}
