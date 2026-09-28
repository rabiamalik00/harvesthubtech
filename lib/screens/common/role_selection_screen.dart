import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pressable_scale.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AgriCare Style Hero Illustration Badge
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5EE), Color(0xFFD8F3DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 18),

                  const Text(
                    'HarvestHub',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.8,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 4),
                  const Text(
                    'Better Farming • Brighter Future',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                  const SizedBox(height: 32),

                  // Header Prompt
                  const Text(
                    'Select Your Account Role',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose how you want to experience the HarvestHub marketplace:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                  const SizedBox(height: 24),

                  // Option 1: Customer Card
                  _buildRoleCard(
                    context,
                    title: 'Customer (Khareeddar)',
                    subtitle: 'Wholesale Buyer & Household',
                    description: 'Browse fresh farm produce, compare prices, order direct, & schedule mandi pickup slots.',
                    icon: Icons.shopping_basket_rounded,
                    color: AppColors.accent,
                    badgeBg: const Color(0xFFFFF3ED),
                    isSelected: auth.selectedRole == AppConstants.roleCustomer,
                    delayMs: 300,
                    onTap: () {
                      auth.setSelectedRole(AppConstants.roleCustomer);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Option 2: Farmer Card
                  _buildRoleCard(
                    context,
                    title: 'Farmer (Kisaan)',
                    subtitle: 'Grower & Producer',
                    description: 'List your harvested crops, manage stock inventory, fulfill orders, & track daily sales without middlemen.',
                    icon: Icons.agriculture_rounded,
                    color: AppColors.primary,
                    badgeBg: AppColors.primarySurface,
                    isSelected: auth.selectedRole == AppConstants.roleFarmer,
                    delayMs: 400,
                    onTap: () {
                      auth.setSelectedRole(AppConstants.roleFarmer);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required Color badgeBg,
    required bool isSelected,
    required int delayMs,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.12 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Icon(icon, size: 28, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delayMs.ms).slideY(begin: 0.08, end: 0);
  }
}
