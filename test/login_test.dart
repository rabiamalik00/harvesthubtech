import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harvesthub/providers/auth_provider.dart';
import 'package:harvesthub/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('Farmer login with Farmer@123 succeeds and sets role to Farmer', () async {
    final auth = AuthProvider();
    final ok = await auth.loginWithEmail(
      email: 'farmer@harvesthub.com',
      password: 'Farmer@123',
    );
    expect(ok, isTrue);
    expect(auth.currentUser?.role, equals('Farmer'));
  });

  test('Customer login with Customer@123 succeeds and sets role to Customer', () async {
    final auth = AuthProvider();
    final ok = await auth.loginWithEmail(
      email: 'customer@harvesthub.com',
      password: 'Customer@123',
    );
    expect(ok, isTrue);
    expect(auth.currentUser?.role, equals('Customer'));
  });

  test('Admin login with admin123 succeeds and sets role to Admin', () async {
    final auth = AuthProvider();
    final ok = await auth.loginWithEmail(
      email: 'admin@harvesthub.com',
      password: 'admin123',
    );
    expect(ok, isTrue);
    expect(auth.currentUser?.role, equals('Admin'));
  });
}
