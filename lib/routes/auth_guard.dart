import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_config/routes.dart';
import '../app_config/theme.dart';
import '../providers/auth_provider.dart';
import '../screens/common/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const AuthGuard({
    super.key,
    required this.requiredRole,
    required this.child,
  });

  static void navigateBasedOnRole(BuildContext context, String role) {
    AppRoutes.navigateToRoleDashboard(context, role);
  }

  static void showAccessDeniedBanner(BuildContext context, {String? customMessage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gpp_bad_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                customMessage ?? 'Access Denied: You do not have permission to access this section.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;

    if (!auth.isAuthenticated || currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAccessDeniedBanner(context, customMessage: 'Please log in to access this page.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser.role != requiredRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAccessDeniedBanner(
          context,
          customMessage: 'Access Denied: Your assigned role (${currentUser.role}) cannot access this section.',
        );
        AppRoutes.navigateToRoleDashboard(context, currentUser.role);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
