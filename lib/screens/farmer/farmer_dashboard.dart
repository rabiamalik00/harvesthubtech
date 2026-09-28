import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/pressable_scale.dart';
import '../common/about_us_screen.dart';
import '../common/contact_us_screen.dart';
import '../common/login_screen.dart';
import '../common/profile_screen.dart';
import 'farmer_reports_screen.dart';
import 'order_fulfillment_screen.dart';
import 'product_management_screen.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final farmerUser = auth.currentUser;
    final farmerId = farmerUser?.uid ?? 'farmer_1';
    final myProducts = productProvider.getFarmerProducts(farmerId);
    final myOrders = orderProvider.getFarmerOrders(farmerId);

    double totalRevenue = myOrders
        .where((o) => o.status != 'Cancelled')
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    final pendingOrders = myOrders.where((o) => o.status == 'Pending').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _FarmerDrawer(auth: auth, farmerUser: farmerUser),
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with gradient
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
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
                      right: 60,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 22,
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.agriculture_rounded, color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (farmerUser?.farmName != null && farmerUser!.farmName!.isNotEmpty)
                                      ? farmerUser.farmName!
                                      : 'Welcome, ${farmerUser?.name ?? "Farmer"}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.storefront_rounded, size: 13, color: Color(0xFFB7E4C7)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        farmerUser?.marketName ?? 'Local Mandi',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFFB7E4C7), fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (pendingOrders > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pendingOrders New',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
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
                          label: 'Total Revenue',
                          value: totalRevenue,
                          prefix: 'Rs. ',
                          icon: Icons.payments_rounded,
                          iconColor: AppColors.primary,
                          badgeBgColor: AppColors.primarySurface,
                        ),
                        AnimatedStatCard(
                          label: 'Active Products',
                          value: myProducts.length,
                          icon: Icons.inventory_2_rounded,
                          iconColor: AppColors.accent,
                          badgeBgColor: const Color(0xFFFFF0E6),
                        ),
                        AnimatedStatCard(
                          label: 'Total Orders',
                          value: myOrders.length,
                          icon: Icons.shopping_bag_rounded,
                          iconColor: AppColors.info,
                          badgeBgColor: const Color(0xFFE0F2FE),
                        ),
                        AnimatedStatCard(
                          label: 'Farmer Rating',
                          value: 4.9,
                          suffix: ' ★',
                          icon: Icons.star_rounded,
                          iconColor: AppColors.gold,
                          badgeBgColor: const Color(0xFFFFF8ED),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 26),

                // Section Header
                const Text(
                  'Farmer Action Hub',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                const SizedBox(height: 4),
                const Text(
                  'Manage your farm listings, orders, and reports',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ).animate().fadeIn(duration: 300.ms, delay: 280.ms),
                const SizedBox(height: 16),

                // Action Cards
                _FarmerActionCard(
                  title: 'Product Inventory & CRUD',
                  subtitle: 'Add new harvest crops, edit prices, update stock quantities',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  badge: '${myProducts.length} listed',
                  delay: 300,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen())),
                ),
                const SizedBox(height: 12),
                _FarmerActionCard(
                  title: 'Order Fulfillment & Status',
                  subtitle: 'View customer orders and update status Pending → Completed',
                  icon: Icons.assignment_outlined,
                  color: AppColors.accent,
                  badge: pendingOrders > 0 ? '$pendingOrders pending' : null,
                  delay: 360,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderFulfillmentScreen())),
                ),
                const SizedBox(height: 12),
                _FarmerActionCard(
                  title: 'Sales & Financial Reports',
                  subtitle: 'Generate and review revenue, units sold, and financial summaries',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.info,
                  delay: 420,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerReportsScreen())),
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

// ─── Farmer Drawer ────────────────────────────────────────────────────────────
class _FarmerDrawer extends StatelessWidget {
  final AuthProvider auth;
  final dynamic farmerUser;

  const _FarmerDrawer({required this.auth, required this.farmerUser});

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
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
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
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Center(child: Icon(Icons.agriculture_rounded, color: Colors.white, size: 28)),
                ),
                const SizedBox(height: 12),
                Text(
                  farmerUser?.farmName?.isNotEmpty == true
                      ? farmerUser!.farmName!
                      : farmerUser?.name ?? 'HarvestHub Farmer',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  farmerUser?.email ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    farmerUser?.marketName ?? 'Local Mandi',
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _DrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Product Inventory CRUD',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.assignment_rounded,
                  label: 'Order Fulfillment',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderFulfillmentScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Sales & Financial Reports',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerReportsScreen()));
                  },
                ),
                const Divider(height: 24, indent: 20, endIndent: 20),
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen(role: 'farmer')));
                  },
                ),
                _DrawerItem(
                  icon: Icons.headset_mic_outlined,
                  label: 'Contact Us',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen(role: 'farmer')));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: AppColors.danger,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (color == null ? AppColors.primary : color!).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color ?? AppColors.primary),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      onTap: onTap,
    );
  }
}

// ─── Action Card ──────────────────────────────────────────────────────────────
class _FarmerActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final int delay;
  final VoidCallback onTap;

  const _FarmerActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
    this.badge,
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
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay)).slideX(begin: 0.04, end: 0);
  }
}
