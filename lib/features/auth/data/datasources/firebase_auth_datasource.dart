import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../models/user_model.dart';

abstract class IAuthDataSource {
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password, String displayName);
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
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
           GoogleSignIn.instance;

  @override
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(credential.user!);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);
    await credential.user!.reload();
    return UserModel.fromFirebase(_firebaseAuth.currentUser!);
  }

  @override
  Future<UserModel> signInWithGoogle() async {

    await _googleSignIn.initialize();

    final googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(oauthCredential);

    return UserModel.fromFirebase(userCredential.user!);
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
        await _firebaseAuth.signInWithCredential(oauthCredential);

    // Apple only sends name on first login — update profile if available.
    final firstName = appleCredential.givenName;
    final lastName = appleCredential.familyName;
    if (firstName != null) {
      await userCredential.user!
          .updateDisplayName('$firstName ${lastName ?? ''}'.trim());
      await userCredential.user!.reload();
    }

    return UserModel.fromFirebase(_firebaseAuth.currentUser!);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(
            (user) => user != null ? UserModel.fromFirebase(user) : null,
          );

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() =>
      _firebaseAuth.currentUser!.sendEmailVerification();

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
}
