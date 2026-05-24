import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data-layer representation of a user.
/// Knows how to map to/from Firebase [User] objects.

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    DateTime? createdAt,
  }) = _UserModel;

  /// Map a Firebase [User] → [UserModel].
  factory UserModel.fromFirebase(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }

  /// Map a Firestore JSON document → [UserModel].
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to domain [UserEntity].
  UserEntity toEntity() => UserEntity(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        emailVerified: emailVerified,
        createdAt: createdAt,
      );
}