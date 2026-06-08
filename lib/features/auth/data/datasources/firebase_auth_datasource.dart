import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutritrack/core/exceptions/app_exception.dart';

import 'package:nutritrack/core/exceptions/firebase_exception_mapper.dart';
import 'package:nutritrack/features/auth/domain/entities/user_entity.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../models/user_model.dart';

abstract class IAuthDataSource {
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password, String displayName, UserRole role);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}

/// Concrete implementation backed by Firebase Auth.
class FirebaseAuthDataSource implements IAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return await UserModel.fromFirebaseUser(cred.user!); // ← await
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password, String displayName, UserRole role) async {
    try {
      // ── Validación previa para pacientes ──────────────────────────────────
      // Solo valida si es paciente — el nutriólogo no necesita patient_link
      if (role == UserRole.patient) {
        final emailKey = email.trim().replaceAll('.', ',');
        final linkDoc = await _firestore
            .collection('patient_links')
            .doc(emailKey)
            .get();

        if (!linkDoc.exists) {
          // Lanza excepción antes de crear nada en Firebase Auth
          throw const PatientNotRegisteredException();
        }
      }

      // ── Crear cuenta ──────────────────────────────────────────────────────
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credential.user!.updateDisplayName(displayName);

      final model = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        roleStr: role.value,
        emailVerified: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(model.toFirestore());

      if (role == UserRole.patient) {
        await _linkPatientUid(uid: credential.user!.uid, email: email);
      }

      return model;
    } catch (e) {
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const UnexpectedException('Inicio con Google cancelado.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      // Verificar si ya existe en Firestore; si no, crear con rol patient por defecto.
      final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
      
      if (!doc.exists) {
        final model = UserModel(
          uid: userCred.user!.uid,
          email: userCred.user!.email ?? '',
          displayName: userCred.user!.displayName,
          photoUrl: userCred.user!.photoURL,
          roleStr: UserRole.patient.value,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _firestore.collection('users').doc(model.uid).set(model.toFirestore());
        return model;
      }
      return UserModel.fromFirestore(doc.data()!);
    } catch (e) {
      if (e is AppException) rethrow;
      throw mapFirebaseException(e);
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256OfString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final userCredential =
        await _auth.signInWithCredential(oauthCredential);

    // Apple only sends name on first login — update profile if available.
    final firstName = appleCredential.givenName;
    final lastName = appleCredential.familyName;
    if (firstName != null) {
      await userCredential.user!
          .updateDisplayName('$firstName ${lastName ?? ''}'.trim());
      await userCredential.user!.reload();
    }

    return UserModel.fromFirebaseUser(_auth.currentUser!);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

   @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().asyncExpand((user) async* {
        if (user == null) {
          yield null;
          return;
        }
        try {
          final model = await UserModel.fromFirebaseUser(user);
          yield model;
        } catch (e) { 
          yield null;
        }
      });

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() =>
      _auth.currentUser!.sendEmailVerification();

  // ── Private helpers for Apple Sign In nonce ──────────────────────────────

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _linkPatientUid({
    required String uid,
    required String email,
  }) async {
    try {
      debugPrint('linkPatientUid START — email: $email');

      final emailKey = email.replaceAll('.', ',');
      final linkDoc = await _firestore
          .collection('patient_links')
          .doc(emailKey)
          .get();

      if (!linkDoc.exists) {
        debugPrint('no se encontró link para $email');
        return;
      }

      final patientDocId = linkDoc.data()!['patientDocId'] as String;
      debugPrint(' patientDocId: $patientDocId');

      // Solo actualiza el uid en patients/ —
      // consultations y appointments los sincroniza el nutriólogo
      await _firestore.collection('patients').doc(patientDocId).update({
        'uid': uid,
      });

      debugPrint('uid linkeado correctamente ');
    } catch (e) {
      debugPrint('_linkPatientUid error: $e');
    }
  }


}


