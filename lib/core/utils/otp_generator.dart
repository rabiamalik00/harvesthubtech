import 'dart:math';

class OtpGenerator {
  /// Generate a cryptographically secure, randomized 6-digit numeric OTP string
  static String generate6DigitOtp() {
    final random = Random.secure();
    final otpInt = 100000 + random.nextInt(900000);
    return otpInt.toString();
  }
}
