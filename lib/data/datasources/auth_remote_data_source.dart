import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../services/storage_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '392257177211-e3n616fue1fjtk8f6f3l44m4p7r3c6kj.apps.googleusercontent.com'
        : null,
  );

  // EmailJS API Credentials
  static const String emailJsServiceId = 'service_pjq7w9w';
  static const String emailJsTemplateId = 'template_w9p3f0n';
  static const String emailJsUserId = 'h21hbo3QI2ceMX7Jq';
  static const String emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  /// Returns the role string ('Customer' | 'Farmer' | 'Admin') from Firestore
  Future<String?> fetchUserRoleFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['role'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Send 6-Digit OTP via EmailJS REST API
  Future<void> sendOtpViaEmailJS({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(emailJsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': emailJsServiceId,
          'template_id': emailJsTemplateId,
          'user_id': emailJsUserId,
          'template_params': {
            'user_email': email,
            'otp_code': otpCode,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw AuthException(
            'Failed to dispatch OTP email (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error sending OTP email: $e');
    }
  }

  /// Register user with Firebase Auth and persist profile in Firestore
  Future<UserModel> registerUserWithFirebase({
    required UserModel user,
    required String password,
  }) async {
    try {
      UserCredential? credential;
      try {
        credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: user.email,
          password: password,
        );
      } catch (_) {
        try {
          credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: user.email,
            password: password,
          );
        } catch (_) {
          credential = null;
        }
      }

      final uid = credential?.user?.uid ?? user.uid;
      final finalUser = user.copyWith(uid: uid);

      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(finalUser.toMap(), SetOptions(merge: true));
      } catch (_) {}

      return finalUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Firebase Auth registration failed.');
    } catch (e) {
      if (e is AuthException) rethrow;
      return user;
    }
  }

  /// Sign in with Email and Password & fetch role from Firestore
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      UserCredential? credential;

      try {
        credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
      } catch (_) {}

      final String? uid = credential?.user?.uid;

      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        }
      }

      // Fallback to local storage
      final localUsers = StorageService.loadUsers();
      final localUser = localUsers.firstWhere(
        (u) => u.email.trim().toLowerCase() == cleanEmail,
        orElse: () =>
            throw AuthException('No user account found with email: $email'),
      );

      if (localUser.isBlocked) {
        throw AuthException(
            'This account has been suspended by the administrator.');
      }

      return localUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login error: $e');
    }
  }

  /// Google Sign-In with Pre-Authentication Role Selection
  Future<UserModel> signInWithGoogle({
    required String preSelectedRole,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google Sign-In was canceled by the user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Failed to retrieve user from Google Auth.');
      }

      final uid = firebaseUser.uid;
      final email = firebaseUser.email ?? '';
      final name = firebaseUser.displayName ?? 'Google User';

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        // Existing user — fetch assigned role to prevent escalation
        final existingUser = UserModel.fromMap(userDoc.data()!);
        await _firestore.collection('users').doc(uid).set(
            {'lastLogin': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
        return existingUser;
      } else {
        // New user — assign preSelectedRole
        final newUser = UserModel(
          uid: uid,
          name: name,
          email: email,
          phone: firebaseUser.phoneNumber ?? '+92 300 0000000',
          role: preSelectedRole,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Authentication failed.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google Sign-In error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
