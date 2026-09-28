import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/common/login_screen.dart';
import '../screens/customer/customer_dashboard.dart';
import '../screens/farmer/farmer_dashboard.dart';
import '../utils/app_colors.dart';
import 'theme.dart';

class AppRoutes {
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String aboutUs = '/about-us';
  static const String contactUs = '/contact-us';

  static const String customerDashboard = '/customer-dashboard';
  static const String productBrowsing = '/product-browsing';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkoutPickup = '/checkout-pickup';
  static const String orderHistory = '/order-history';
  static const String aiAssistant = '/ai-assistant';

  static const String farmerDashboard = '/farmer-dashboard';
  static const String productManagement = '/product-management';
  static const String orderFulfillment = '/order-fulfillment';
  static const String farmerReports = '/farmer-reports';

  static const String adminDashboard = '/admin-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageCategories = '/manage-categories';
  static const String platformReports = '/platform-reports';

  /// Central Route Guard enforcing strict Role-Based Access Control (RBAC)
  static Widget guardRoute({required String requiredRole, required Widget child}) {
    return AuthGuard(requiredRole: requiredRole, child: child);
  }

  /// Helper to route authenticated user directly to their assigned role dashboard
  static void navigateToRoleDashboard(BuildContext context, String role) {
    Widget destination;
    if (role == 'Farmer') {
      destination = const CustomerFarmerAdminGuard(
        requiredRole: 'Farmer',
        child: FarmerDashboard(),
      );
    } else if (role == 'Admin') {
      destination = const CustomerFarmerAdminGuard(
        requiredRole: 'Admin',
        child: AdminDashboard(),
      );
    } else {
      destination = const CustomerFarmerAdminGuard(
        requiredRole: 'Customer',
        child: CustomerDashboard(),
      );
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }
}

class AuthGuard extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const AuthGuard({
    super.key,
    required this.requiredRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerFarmerAdminGuard(requiredRole: requiredRole, child: child);
  }
}

class CustomerFarmerAdminGuard extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const CustomerFarmerAdminGuard({
    super.key,
    required this.requiredRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (!auth.isAuthenticated || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to access HarvestHub.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user.role != requiredRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Access Denied: Your account role (${user.role}) cannot access this dashboard.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        AppRoutes.navigateToRoleDashboard(context, user.role);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
