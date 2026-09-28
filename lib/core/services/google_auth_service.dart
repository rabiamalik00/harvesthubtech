import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../app_config/constants.dart';
import '../../models/user_model.dart';
import '../../services/storage_service.dart';
import 'firebase_service.dart';

class GoogleAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn(
    clientId: kIsWeb
        ? '392257177211-e3n616fue1fjtk8f6f3l44m4p7r3c6kj.apps.googleusercontent.com'
        : null,
    serverClientId: '392257177211-e3n616fue1fjtk8f6f3l44m4p7r3c6kj.apps.googleusercontent.com',
  );

  /// Google Sign-In with Pre-Authentication Role Selection
  /// If existing user: fetches assigned role from Firestore/local storage to prevent escalation.
  /// If new user: saves user record with pre-selected role in Firestore & local storage.
  Future<UserModel?> signInWithGoogle({required String preSelectedRole}) async {
    try {
      // Disallow admin role assignment via Google Sign-In
      if (preSelectedRole == AppConstants.roleAdmin) {
        throw Exception(
            'Admin role cannot be assigned via Google sign-in. Please log in with Administrator credentials.');
      }

      String? uid;
      String? email;
      String? displayName;
      String? phoneNumber;

      if (kIsWeb) {
        // Native Firebase popup authentication on Flutter Web
        try {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          // Force Google to show the account picker screen each time so users can switch accounts
          googleProvider.setCustomParameters({
            'prompt': 'select_account',
          });
          final UserCredential userCredential =
              await _auth.signInWithPopup(googleProvider);
          final User? fbUser = userCredential.user;
          if (fbUser != null) {
            uid = fbUser.uid;
            email = fbUser.email;
            displayName = fbUser.displayName;
            phoneNumber = fbUser.phoneNumber;
          }
        } catch (popupErr) {
          debugPrint('signInWithPopup failed, falling back to GoogleSignIn: $popupErr');
          // If user closed the popup, cancel gracefully
          final errStr = popupErr.toString().toLowerCase();
          if (errStr.contains('popup_closed') ||
              errStr.contains('cancelled') ||
              errStr.contains('canceled')) {
            return null;
          }

          try {
            await _googleSignIn.signOut();
          } catch (_) {}
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return null; // Canceled by user

          uid = 'google_${googleUser.id}';
          email = googleUser.email;
          displayName = googleUser.displayName;

          try {
            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            final UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            final User? fbUser = userCredential.user;
            if (fbUser != null) {
              uid = fbUser.uid;
              email = fbUser.email ?? email;
              displayName = fbUser.displayName ?? displayName;
              phoneNumber = fbUser.phoneNumber;
            }
          } catch (_) {
            // Offline/credential fallback
          }
        }
      } else {
        // Mobile / other platforms
        try {
          try {
            await _googleSignIn.signOut();
          } catch (_) {}
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return null; // Canceled by user

          uid = 'google_${googleUser.id}';
          email = googleUser.email;
          displayName = googleUser.displayName;

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          try {
            final UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            final User? fbUser = userCredential.user;
            if (fbUser != null) {
              uid = fbUser.uid;
              email = fbUser.email ?? email;
              displayName = fbUser.displayName ?? displayName;
              phoneNumber = fbUser.phoneNumber;
            }
          } catch (_) {
            // Local fallback
          }
        } catch (e) {
          final err = e.toString();
          if (err.contains('MissingPluginException') ||
              err.contains('UnimplementedError')) {
            throw Exception(
                'Google Sign-In is only available on Web, Android, and iOS. Please log in using Email & Password.');
          }
          if (err.contains('10') ||
              err.contains('DEVELOPER_ERROR') ||
              err.contains('sign_in_failed')) {
            throw Exception(
                'Google Sign-In requires SHA-1 registration in Firebase Console. Please register fingerprint CB:52:31:2F:2E:6C:D4:4D:68:D5:16:61:36:68:4C:47:40:AE:0D:9F in Firebase Console, or log in with Email & Password.');
          }
          rethrow;
        }
      }

      if (uid == null) return null;

      // 1. Check if user already exists in Firestore or Local Storage to maintain assigned role
      UserModel? finalUser;
      try {
        final userDoc = await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          finalUser = UserModel.fromMap(userDoc.data()!, uid);
        }
      } catch (_) {}

      if (finalUser == null) {
        final localUsers = StorageService.loadUsers();
        try {
          finalUser = localUsers.firstWhere(
            (u) =>
                u.uid == uid ||
                (email != null &&
                    email.isNotEmpty &&
                    u.email.toLowerCase() == email.toLowerCase()),
          );
        } catch (_) {}
      }

      // 2. If new user, create user record with preSelectedRole
      if (finalUser == null) {
        finalUser = UserModel(
          uid: uid,
          name: (displayName != null && displayName.isNotEmpty)
              ? displayName
              : 'Google User',
          email: email ?? '',
          phone: phoneNumber ?? '+92 300 0000000',
          role: preSelectedRole,
          createdAt: DateTime.now(),
        );

        try {
          await _firestore
              .collection(AppConstants.collectionUsers)
              .doc(uid)
              .set(finalUser.toMap(), SetOptions(merge: true));
        } catch (_) {
          await FirebaseService.saveUserRecord(finalUser);
        }
      }

      // 3. Persist in local storage so page reload preserves the session
      final allUsers = StorageService.loadUsers();
      final idx = allUsers.indexWhere(
        (u) => u.uid == finalUser!.uid || u.email.toLowerCase() == finalUser.email.toLowerCase(),
      );
      if (idx != -1) {
        allUsers[idx] = finalUser;
      } else {
        allUsers.add(finalUser);
      }
      await StorageService.saveUsers(allUsers);
      await StorageService.setCurrentUser(finalUser);

      return finalUser;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
    } catch (_) {}
  }
}
