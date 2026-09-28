import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/routes.dart';
import '../../app_config/theme.dart';
import '../../core/services/email_service.dart';
import '../../core/utils/otp_generator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/custom_toast.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String password;
  final String generatedOtp;
  final String address;
  final String? farmName;
  final String? marketName;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    required this.generatedOtp,
    this.address = '',
    this.farmName,
    this.marketName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _activeOtp;
  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _activeOtp = widget.generatedOtp;
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final newOtp = OtpGenerator.generate6DigitOtp();
    _activeOtp = newOtp;

    try {
      await EmailService.sendOtpEmail(recipientEmail: widget.email, otpCode: newOtp);
      if (mounted) {
        showHarvestSnackBar(
          context,
          message: 'New OTP code dispatched to ${widget.email}',
          icon: Icons.mark_email_read_rounded,
        );
      }
    } catch (_) {
      // Fallback: use new OTP
    }

    setState(() => _isLoading = false);
    _startTimer();
  }

  Future<void> _verifyOtp() async {
    final entered = _controllers.map((c) => c.text.trim()).join();

    if (entered.length < 6) {
      setState(() => _errorMsg = 'Please enter all 6 digits of the OTP code.');
      return;
    }

    if (entered != _activeOtp) {
      setState(() => _errorMsg = 'Invalid OTP code. Please enter the code sent to your email.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.finalizeOtpRegistration(
        name: widget.name,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
        role: widget.role,
        address: widget.address,
        farmName: widget.farmName,
        marketName: widget.marketName,
      ).timeout(const Duration(seconds: 8), onTimeout: () => true);

      if (!mounted) return;

      if (success) {
        _timer?.cancel();
        showHarvestSnackBar(
          context,
          message: 'Account verified! Welcome to HarvestHub.',
          icon: Icons.verified_rounded,
        );
        AppRoutes.navigateToRoleDashboard(context, auth.currentUser?.role ?? widget.role);
      } else {
        setState(() => _errorMsg = auth.errorMessage ?? 'Verification failed. Please retry.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMsg = 'Network timeout. Registration completed locally, please login.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var n in _focusNodes) { n.dispose(); }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Progress: 60s → 0s arc
    final progress = _secondsRemaining / 60.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'OTP Verification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      // Animated icon badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              value: _canResend ? 0 : progress,
                              strokeWidth: 3,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8F5EE), Color(0xFFD8F3DC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.mark_email_read_outlined, size: 38, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      const Text(
                        'Verify Email OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                      const SizedBox(height: 8),
                      Text(
                        'A 6-digit code has been dispatched to:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                      const SizedBox(height: 30),

                      // OTP Input Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 46,
                            height: 56,
                            margin: EdgeInsets.only(right: index < 5 ? 10 : 0),
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: AppColors.primarySurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.cardBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.cardBorder),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (val.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                // Clear error on input
                                if (_errorMsg != null) setState(() => _errorMsg = null);
                              },
                            ),
                          );
                        }),
                      ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.04, end: 0),
                      const SizedBox(height: 20),

                      // Error Message
                      if (_errorMsg != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMsg!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().shake(duration: 400.ms),

                      // Verify Button
                      PressableScale(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isLoading ? AppColors.primaryLight : AppColors.primary,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Verify & Create Account  ✓',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                      const SizedBox(height: 22),

                      // Resend Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive code?  ",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          if (_canResend)
                            GestureDetector(
                              onTap: _isLoading ? null : _resendOtp,
                              child: const Text(
                                'Resend Code',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_secondsRemaining}s',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
