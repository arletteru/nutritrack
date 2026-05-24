import 'package:equatable/equatable.dart';

/// Pure domain entity. Zero Firebase dependencies.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
  });

  bool get hasName => displayName != null && displayName!.isNotEmpty;

  String get initials {
    if (!hasName) return email.substring(0, 1).toUpperCase();
    final parts = displayName!.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, emailVerified];

  @override
  String toString() =>
      'UserEntity(uid: $uid, email: $email, displayName: $displayName)';
}
