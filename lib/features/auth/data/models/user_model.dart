import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String uid,
    required String email,
    // Firestore guarda el rol como String; el converter lo mapea.
    @JsonKey(name: 'role') required String roleStr,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    String? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // ── Firestore → UserModel ─────────────────────────────────────────────────
  factory UserModel.fromFirestore(Map<String, dynamic> data) =>
      UserModel.fromJson(data);

  // ── Firebase Auth User + Firestore role ───────────────────────────────────
  static Future<UserModel> fromFirebaseUser(User user) async {
  try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // ← sin ! — si el doc no existe aún, usar valores por defecto
      final roleStr = doc.exists
          ? (doc.data()?['role'] as String? ?? 'patient')
          : 'patient';

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        roleStr: roleStr,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
        createdAt: user.metadata.creationTime?.toIso8601String(),
      );
    } catch (e) {
      debugPrint('fromFirebaseUser error: $e');
      // Retornar modelo básico en lugar de explotar
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        roleStr: 'patient',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );
    }
  }

  // ── UserModel → Firestore map ──────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => toJson();

  // ── UserModel → domain UserEntity ─────────────────────────────────────────
  UserEntity toEntity() => UserEntity(
        uid: uid,
        email: email,
        role: roleStr == 'nutriologist' ? UserRole.nutriologist : UserRole.patient,
        displayName: displayName,
        photoUrl: photoUrl,
        emailVerified: emailVerified,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
