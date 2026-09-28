import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app_config/constants.dart';

class EmailService {
  /// Send 6-Digit OTP via EmailJS HTTP POST API
  static Future<void> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
  }) async {
    try {
      final url = Uri.parse(AppConstants.emailJsApiUrl);
      final Map<String, dynamic> payload = {
        'service_id': AppConstants.emailJsServiceId,
        'template_id': AppConstants.emailJsTemplateId,
        'user_id': AppConstants.emailJsUserId,
        'template_params': {
          'user_email': recipientEmail,
          'otp_code': otpCode,
        },
      };

      if (AppConstants.emailJsPrivateKey.trim().isNotEmpty) {
        payload['accessToken'] = AppConstants.emailJsPrivateKey.trim();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('EmailJS Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
}
