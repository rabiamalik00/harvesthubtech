import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_config/routes.dart';
import '../app_config/theme.dart';
import '../providers/auth_provider.dart';
import '../screens/common/about_us_screen.dart';
import '../screens/common/contact_us_screen.dart';
import '../screens/common/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final isFarmer = user?.isFarmer ?? false;
    final isAdmin = user?.isAdmin ?? false;
    final isCustomer = user?.isCustomer ?? true;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFarmer
                            ? Icons.agriculture
                            : (isAdmin ? Icons.admin_panel_settings : Icons.person),
                        size: 32,
                        color: isAdmin ? Colors.purple : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'HarvestHub User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // Role Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.purple : (isFarmer ? AppColors.primaryDark : AppColors.accent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFarmer ? Icons.grass : (isAdmin ? Icons.security : Icons.shopping_bag),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Role: ${user?.role ?? "Customer"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Navigation
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (isCustomer) ...[
                  ListTile(
                    leading: const Icon(Icons.storefront, color: AppColors.primary),
                    title: const Text('Customer Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      AppRoutes.navigateToRoleDashboard(context, 'Customer');
                    },
                  ),
                ] else if (isFarmer) ...[
                  ListTile(
                    leading: const Icon(Icons.agriculture, color: AppColors.primary),
                    title: const Text('Farmer Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      AppRoutes.navigateToRoleDashboard(context, 'Farmer');
                    },
                  ),
                ] else if (isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                    title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    onTap: () {
                      Navigator.pop(context);
                      AppRoutes.navigateToRoleDashboard(context, 'Admin');
                    },
                  ),
                ],

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support_outlined),
                  title: const Text('Contact Us'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(context);
                    auth.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
