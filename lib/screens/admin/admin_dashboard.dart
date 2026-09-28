import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/pressable_scale.dart';
import '../common/contact_us_screen.dart';
import '../common/login_screen.dart';
import 'admin_manage_orders_screen.dart';
import 'admin_manage_products_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_users_screen.dart';
import 'platform_reports_screen.dart';

// Admin theme colors
const _adminPrimary = Color(0xFF5B21B6);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final adminUser = auth.currentUser;
    final reports = orderProvider.generatePlatformReports(auth.users);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _AdminDrawer(auth: auth, adminUser: adminUser),
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar — purple admin theme
          SliverAppBar(
            expandedHeight: 165,
            pinned: true,
            backgroundColor: _adminPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B0764), Color(0xFF5B21B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      right: 80,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 22,
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  adminUser?.name ?? 'Platform Administrator',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Admin Governance Portal',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFDDD6FE), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Responsive Stats Grid
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.sizeOf(context).width;
                    final statsColumns = screenWidth > 750 ? 4 : 2;
                    final statsAspect = screenWidth > 750 ? 1.55 : (screenWidth < 360 ? 1.08 : 1.20);

                    return GridView.count(
                      crossAxisCount: statsColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: statsAspect,
                      children: [
                        AnimatedStatCard(
                          label: 'Platform GMV',
                          value: (reports['totalRevenue'] as double),
                          prefix: 'Rs. ',
                          icon: Icons.payments_rounded,
                          iconColor: _adminPrimary,
                          badgeBgColor: const Color(0xFFF5F3FF),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlatformReportsScreen())),
                        ),
                        AnimatedStatCard(
                          label: 'Total Orders',
                          value: reports['totalOrders'] as int,
                          icon: Icons.shopping_bag_rounded,
                          iconColor: AppColors.accent,
                          badgeBgColor: const Color(0xFFFFF0E6),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageOrdersScreen())),
                        ),
                        AnimatedStatCard(
                          label: 'Active Farmers',
                          value: reports['activeFarmersCount'] as int,
                          icon: Icons.agriculture_rounded,
                          iconColor: AppColors.primary,
                          badgeBgColor: AppColors.primarySurface,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlatformReportsScreen())),
                        ),
                        AnimatedStatCard(
                          label: 'Registered Users',
                          value: auth.users.length,
                          icon: Icons.people_rounded,
                          iconColor: AppColors.info,
                          badgeBgColor: const Color(0xFFE0F2FE),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 26),

                // Section Header
                const Text(
                  'Admin Management Console',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                const SizedBox(height: 4),
                const Text(
                  'Govern all platform operations from one place',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 300.ms, delay: 280.ms),
                const SizedBox(height: 16),

                // Admin Action Cards
                _AdminActionCard(
                  title: 'Manage All Products',
                  subtitle: 'View, edit price/stock, and remove products from the platform',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.deepOrange,
                  delay: 300,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageProductsScreen())),
                ),
                const SizedBox(height: 12),
                _AdminActionCard(
                  title: 'Manage All Orders',
                  subtitle: 'Search, filter, and update order statuses across the platform',
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.teal,
                  delay: 350,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageOrdersScreen())),
                ),
                const SizedBox(height: 12),
                _AdminActionCard(
                  title: 'Manage Customers & Farmers',
                  subtitle: 'View user accounts, filter by role, and delete records',
                  icon: Icons.people_outline_rounded,
                  color: _adminPrimary,
                  delay: 400,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                ),
                const SizedBox(height: 12),
                _AdminActionCard(
                  title: 'Manage Product Categories',
                  subtitle: 'Add and organize categories (Fruits, Vegetables, Organic, etc.)',
                  icon: Icons.category_outlined,
                  color: AppColors.primary,
                  delay: 450,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())),
                ),
                const SizedBox(height: 12),
                _AdminActionCard(
                  title: 'Platform Analytics & Reports',
                  subtitle: 'View total orders, market revenue, and most active growers',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.accent,
                  delay: 500,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlatformReportsScreen())),
                ),
                const SizedBox(height: 12),
                _AdminActionCard(
                  title: 'Queries & Customer Reviews',
                  subtitle: 'Review farmer questions, customer support inquiries, and verified buyer reviews',
                  icon: Icons.rate_review_outlined,
                  color: Colors.indigo,
                  delay: 550,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen(role: 'admin'))),
                ),
                const SizedBox(height: 28),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Admin Drawer ─────────────────────────────────────────────────────────────
class _AdminDrawer extends StatelessWidget {
  final AuthProvider auth;
  final dynamic adminUser;

  const _AdminDrawer({required this.auth, required this.adminUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B0764), Color(0xFF5B21B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Center(child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28)),
                ),
                const SizedBox(height: 10),
                Text(
                  adminUser?.name ?? 'Platform Administrator',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  adminUser?.email ?? '',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFDDD6FE)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Administrator', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _AdminDrawerItem(icon: Icons.inventory_2_rounded, label: 'Manage Products', color: Colors.deepOrange, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageProductsScreen())); }),
                _AdminDrawerItem(icon: Icons.shopping_bag_rounded, label: 'Manage Orders', color: Colors.teal, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageOrdersScreen())); }),
                _AdminDrawerItem(icon: Icons.people_rounded, label: 'Manage Users', color: _adminPrimary, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())); }),
                _AdminDrawerItem(icon: Icons.category_rounded, label: 'Manage Categories', color: AppColors.primary, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())); }),
                _AdminDrawerItem(icon: Icons.bar_chart_rounded, label: 'Platform Reports', color: AppColors.accent, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PlatformReportsScreen())); }),
                const Divider(height: 24, indent: 20, endIndent: 20),
                _AdminDrawerItem(
                  icon: Icons.rate_review_outlined,
                  label: 'Queries & Reviews',
                  color: Colors.amber.shade800,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen(role: 'admin')));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _AdminDrawerItem(
            icon: Icons.logout_rounded,
            label: 'Logout Admin',
            isLogout: true,
            onTap: () {
              Navigator.pop(context);
              auth.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isLogout;

  const _AdminDrawerItem({required this.icon, required this.label, required this.onTap, this.color, this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    final c = isLogout ? AppColors.danger : (color ?? _adminPrimary);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: c),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLogout ? AppColors.danger : AppColors.textPrimary)),
      onTap: onTap,
    );
  }
}

// ─── Admin Action Card ────────────────────────────────────────────────────────
class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay)).slideX(begin: 0.04, end: 0);
  }
}
