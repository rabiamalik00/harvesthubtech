import '../../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<String?> fetchUserRoleFromFirestore(String uid);
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> sendOtpViaEmailJS({
    required String email,
    required String otpCode,
  });
  Future<UserModel> registerUserWithFirebase({
    required UserModel user,
    required String password,
  });
  Future<UserModel> signInWithGoogle({
    required String preSelectedRole,
  });
  Future<void> signOut();
}
