import '../../domain/repositories/auth_repository.dart';
import '../../models/user_model.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<UserModel?> getCurrentUser() async {
    return null;
  }

  @override
  Future<String?> fetchUserRoleFromFirestore(String uid) async {
    return await _remoteDataSource.fetchUserRoleFromFirestore(uid);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendOtpViaEmailJS({
    required String email,
    required String otpCode,
  }) async {
    await _remoteDataSource.sendOtpViaEmailJS(
      email: email,
      otpCode: otpCode,
    );
  }

  @override
  Future<UserModel> registerUserWithFirebase({
    required UserModel user,
    required String password,
  }) async {
    return await _remoteDataSource.registerUserWithFirebase(
      user: user,
      password: password,
    );
  }

  @override
  Future<UserModel> signInWithGoogle({
    required String preSelectedRole,
  }) async {
    return await _remoteDataSource.signInWithGoogle(
      preSelectedRole: preSelectedRole,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }
}
