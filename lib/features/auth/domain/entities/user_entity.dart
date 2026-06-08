import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

enum UserRole {
  nutriologist('nutriologist'),
  patient('patient');

  // El valor exacto que se guardará en la base de datos
  final String value;
  const UserRole(this.value);

  // Método ultra seguro para convertir un String de Firestore de vuelta al Enum
  static UserRole fromString(String roleStr) {
    return UserRole.values.firstWhere(
      (element) => element.value == roleStr,
      orElse: () => UserRole.patient, // Rol por defecto por si pasa algo raro
    );
  }
}

@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._(); // constructor privado para agregar métodos

  const factory UserEntity({
    required String uid,
    required String email,
    required UserRole role,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    DateTime? createdAt,
  }) = _UserEntity;

  // ── Computed helpers ───────────────────────────────────────────────────────
  bool get isNutriologist => role == UserRole.nutriologist;
  bool get isPatient => role == UserRole.patient;

  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    final parts = displayName!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
