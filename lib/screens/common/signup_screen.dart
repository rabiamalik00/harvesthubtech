import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/custom_toast.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _addressController = TextEditingController();
  final _farmNameController = TextEditingController();
  String _selectedMarket = 'Faisalabad Model Mandi Market';
  bool _obscurePass = true;
  late String _selectedRole;

  final List<String> _mandiMarkets = [
    'Faisalabad Model Mandi Market',
    'Lahore Model Agriculture Bazaar',
    'Multan Grain & Vegetable Mandi',
    'Rawalpindi Sabzi Mandi',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _selectedRole = auth.selectedRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final isFarmer = _selectedRole == AppConstants.roleFarmer;

    final otpResult = await auth.initiateSignup(
      name: _nameController.text.trim(),
      email: email,
      phone: _phoneController.text.trim(),
      password: _passController.text,
      role: _selectedRole,
      address: _addressController.text.trim(),
      farmName: isFarmer ? _farmNameController.text.trim() : null,
      marketName: isFarmer ? _selectedMarket : null,
    );

    if (auth.errorMessage != null) {
      if (!mounted) return;
      showHarvestSnackBar(
        context,
        message: auth.errorMessage!,
        icon: Icons.error_outline_rounded,
        backgroundColor: AppColors.danger,
      );
      return;
    }

    if (otpResult != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            name: _nameController.text.trim(),
            email: email,
            phone: _phoneController.text.trim(),
            role: _selectedRole,
            password: _passController.text,
            generatedOtp: otpResult,
            address: _addressController.text.trim(),
            farmName: isFarmer ? _farmNameController.text.trim() : null,
            marketName: isFarmer ? _selectedMarket : null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isFarmer = _selectedRole == AppConstants.roleFarmer;

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
                  Expanded(
                    child: Text(
                      '$_selectedRole Registration',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon + Header
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFarmer
                                  ? [const Color(0xFFD8F3DC), const Color(0xFFB7E4C7)]
                                  : [const Color(0xFFFFF0E6), const Color(0xFFFFDDD1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isFarmer ? AppColors.primary : AppColors.accent).withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isFarmer ? Icons.agriculture_rounded : Icons.person_add_rounded,
                              size: 40,
                              color: isFarmer ? AppColors.primary : AppColors.accent,
                            ),
                          ),
                        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 12),
                        Text(
                          'Create $_selectedRole Account',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                        const SizedBox(height: 4),
                        const Text(
                          'Fill the form to generate your 6-digit OTP code',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                        const SizedBox(height: 18),

                        // Role Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: PressableScale(
                                  onPressed: () => setState(() => _selectedRole = AppConstants.roleCustomer),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == AppConstants.roleCustomer
                                          ? const Color(0xFFFFF3ED)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedRole == AppConstants.roleCustomer
                                            ? AppColors.accent
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.shopping_basket_rounded,
                                            size: 16,
                                            color: _selectedRole == AppConstants.roleCustomer
                                                ? AppColors.accent
                                                : AppColors.textLight),
                                        const SizedBox(width: 6),
                                        Text('Customer',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: _selectedRole == AppConstants.roleCustomer
                                                  ? AppColors.accent
                                                  : AppColors.textSecondary,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: PressableScale(
                                  onPressed: () => setState(() => _selectedRole = AppConstants.roleFarmer),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedRole == AppConstants.roleFarmer
                                          ? AppColors.primarySurface
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedRole == AppConstants.roleFarmer
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.agriculture_rounded,
                                            size: 16,
                                            color: _selectedRole == AppConstants.roleFarmer
                                                ? AppColors.primary
                                                : AppColors.textLight),
                                        const SizedBox(width: 6),
                                        Text('Farmer',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: _selectedRole == AppConstants.roleFarmer
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                        const SizedBox(height: 20),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                                ),
                                validator: (v) => Validators.validateRequired(v, 'Full Name'),
                              ),
                              const SizedBox(height: 14),
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
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Phone Number',
                                  hintText: '+92 300 1234567',
                                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                                ),
                                validator: Validators.validatePhone,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passController,
                                obscureText: _obscurePass,
                                decoration: InputDecoration(
                                  labelText: 'Set Password',
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
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Full Address / Location',
                                  hintText: 'e.g. House 12, Gulberg III, Lahore',
                                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                                ),
                                validator: (v) => Validators.validateRequired(v, 'Address'),
                              ),
                              if (isFarmer) ...[
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _farmNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Farm / Agricultural Business Name',
                                    hintText: 'e.g. Al-Madina Organic Farm',
                                    prefixIcon: Icon(Icons.agriculture_outlined, color: AppColors.primary),
                                  ),
                                  validator: (v) =>
                                      isFarmer ? Validators.validateRequired(v, 'Farm / Business Name') : null,
                                ),
                                const SizedBox(height: 14),
                                DropdownButtonFormField<String>(
                                  value: _selectedMarket,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Assigned Mandi / Market',
                                    prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.primary),
                                  ),
                                  items: _mandiMarkets
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m,
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedMarket = val);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.06, end: 0),
                        const SizedBox(height: 22),

                        // CTA Button
                        PressableScale(
                          onPressed: auth.isLoading ? null : _handleSignup,
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
                                  : const Text(
                                      'Send 6-Digit Email OTP  →',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Already have an account? ',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
