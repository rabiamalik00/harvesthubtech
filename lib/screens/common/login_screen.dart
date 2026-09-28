import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/constants.dart';
import '../../app_config/routes.dart';
import '../../app_config/theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/custom_toast.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';
import 'role_selection_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passController.text,
    );

    if (success && auth.currentUser != null && mounted) {
      AppRoutes.navigateToRoleDashboard(context, auth.currentUser!.role);
    } else if (mounted && auth.errorMessage != null) {
      showHarvestSnackBar(
        context,
        message: auth.errorMessage!,
        icon: Icons.error_outline_rounded,
        backgroundColor: AppColors.danger,
      );
    }
  }

  void _handleGoogleLoginModal() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String selectedRole = auth.selectedRole;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.g_mobiledata, color: Colors.blue, size: 34),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Select Role for Google Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select your HarvestHub role before proceeding with Google Sign-In:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PressableScale(
                        onPressed: () => setModalState(() => selectedRole = AppConstants.roleCustomer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedRole == AppConstants.roleCustomer
                                ? const Color(0xFFFFF3ED)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedRole == AppConstants.roleCustomer
                                  ? AppColors.accent
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_basket_rounded,
                                  color: selectedRole == AppConstants.roleCustomer
                                      ? AppColors.accent
                                      : AppColors.textLight,
                                  size: 22),
                              const SizedBox(height: 4),
                              Text('Customer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selectedRole == AppConstants.roleCustomer
                                        ? AppColors.accent
                                        : AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PressableScale(
                        onPressed: () => setModalState(() => selectedRole = AppConstants.roleFarmer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedRole == AppConstants.roleFarmer
                                ? AppColors.primarySurface
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedRole == AppConstants.roleFarmer
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.agriculture_rounded,
                                  color: selectedRole == AppConstants.roleFarmer
                                      ? AppColors.primary
                                      : AppColors.textLight,
                                  size: 22),
                              const SizedBox(height: 4),
                              Text('Farmer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selectedRole == AppConstants.roleFarmer
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await auth.loginWithGoogle(preSelectedRole: selectedRole);
                  if (!mounted) return;
                  if (success && auth.currentUser != null) {
                    AppRoutes.navigateToRoleDashboard(context, auth.currentUser!.role);
                  } else if (auth.errorMessage != null) {
                    showHarvestSnackBar(
                      context,
                      message: auth.errorMessage!,
                      icon: Icons.error_outline_rounded,
                      backgroundColor: AppColors.danger,
                    );
                  }
                },
                child: const Text('Continue with Google'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botanical Logo Badge
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5EE), Color(0xFFD8F3DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.eco_rounded, size: 44, color: AppColors.primary),
                    ),
                  ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 14),
                  const Text(
                    'HarvestHub',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.8,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Login as ${auth.selectedRole}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                  const SizedBox(height: 22),

                  // Role Switch Pill
                  PressableScale(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Logging in as ${auth.selectedRole}  •  Tap to switch',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: 22),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign In to Your Account',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enter your registered email & password to continue:',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'you@email.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passController,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textLight,
                                ),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 22),

                          // Primary Login Button
                          PressableScale(
                            onPressed: auth.isLoading ? null : _handleEmailLogin,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: auth.isLoading ? AppColors.primaryLight : AppColors.primary,
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
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        'Log In as ${auth.selectedRole}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Google Login Button
                          PressableScale(
                            onPressed: auth.isLoading ? null : _handleGoogleLoginModal,
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata, color: Colors.blue, size: 26),
                                  SizedBox(width: 8),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 18),

                  // Signup Link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Register Here',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                  const SizedBox(height: 20),

                  // About/Contact Links
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text('About Us'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.headset_mic_outlined, size: 16),
                        label: const Text('Contact Us'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
