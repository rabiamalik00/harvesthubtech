import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';

class AboutUsScreen extends StatelessWidget {
  final String? role;

  const AboutUsScreen({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final isCustomer = role?.toLowerCase() == 'customer';
    final isFarmer = role?.toLowerCase() == 'farmer';
    final isAdmin = role?.toLowerCase() == 'admin';

    // Role-specific theme styling
    final gradientColors = isAdmin
        ? const [Color(0xFF3B0764), Color(0xFF6D28D9)]
        : (isFarmer
            ? const [Color(0xFF78350F), Color(0xFFB45309)]
            : const [Color(0xFF1B4332), Color(0xFF40916C)]);

    final headerIcon = isAdmin
        ? Icons.admin_panel_settings_rounded
        : (isFarmer ? Icons.agriculture_rounded : Icons.eco_rounded);

    final headerTitle = isAdmin
        ? 'Platform Governance'
        : (isFarmer ? 'HarvestHub for Farmers' : (isCustomer ? 'HarvestHub for Customers' : 'HarvestHub Marketplace'));

    final headerSubtitle = isAdmin
        ? 'Centralized Management, Trust & Market Analytics'
        : (isFarmer
            ? 'Digital Mandi Access • Fair Price Discovery • Direct Payouts'
            : (isCustomer
                ? 'Fresh Produce • Traceable Origins • Fair Prices'
                : 'eGreen Basket — Local Farm Marketplace'));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Botanical / Role-specific gradient header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: gradientColors.last,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative orbs
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: 40,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Header Content
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                            ),
                            child: Icon(headerIcon, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            headerTitle,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            headerSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isCustomer) ...[
                          _AboutCard(
                            icon: Icons.storefront_rounded,
                            iconColor: AppColors.primary,
                            title: 'Farm-to-Kitchen Direct Supply',
                            content:
                                'HarvestHub connects you directly with local farmers across Faisalabad and Punjab mandis. When you buy here, produce is harvested fresh and prepared specifically for your pickup slot — avoiding weeks of cold storage and artificial preservatives.',
                            delay: 0,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.verified_user_rounded,
                            iconColor: AppColors.gold,
                            title: 'Transparent Pricing & Origin Tracing',
                            content:
                                'Every crop listing displays the grower\'s name, farm location, and local mandi hub. Without middleman markups (Arthi commissions), you receive authentic wholesale-grade rates while farmers receive fair compensation for their hard labor.',
                            delay: 60,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.schedule_rounded,
                            iconColor: AppColors.info,
                            title: 'Flexible Pickup Slots & Live Wishlists',
                            content:
                                'Schedule your pickup time at designated local mandi collection spots with zero queueing. Save favorite recurring crops to your personal wishlist and receive restock notifications whenever fresh harvests arrive.',
                            delay: 120,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.smart_toy_rounded,
                            iconColor: const Color(0xFF2563EB),
                            title: '24/7 AI Produce & Storage Assistant',
                            content:
                                'Our embedded AI Farm Assistant helps you evaluate crop freshness, optimal refrigeration tips, shelf-life maximization, and nutritional values before and after your purchase.',
                            delay: 180,
                          ),
                        ] else if (isFarmer) ...[
                          _AboutCard(
                            icon: Icons.phonelink_ring_rounded,
                            iconColor: const Color(0xFFB45309),
                            title: 'Direct Digital Mandi Access',
                            content:
                                'Break free from the exploitative traditional market chain. HarvestHub gives you a direct digital presence to list seasonal harvests directly to thousands of verified urban and semi-urban consumers in your district.',
                            delay: 0,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.price_check_rounded,
                            iconColor: AppColors.primary,
                            title: 'Transparent Price Setting & Zero Hidden Cuts',
                            content:
                                'You decide your own rate per kg, crate, or bundle. No deductions for unsolicited broker cuts or unexpected handling charges. Complete visibility into customer demand and local mandi trends.',
                            delay: 60,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.inventory_2_rounded,
                            iconColor: AppColors.info,
                            title: 'Real-Time Inventory & Order Tracking',
                            content:
                                'Manage crop listings, update stock levels when new harvest arrives, and process customer orders through an easy 4-stage fulfillment pipeline: Pending → Processing → Ready for Pickup → Completed.',
                            delay: 120,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.analytics_rounded,
                            iconColor: const Color(0xFF10B981),
                            title: 'Financial & Sales Reporting',
                            content:
                                'Generate automated daily, weekly, and monthly revenue summaries. Track popular crops, units sold, and repeat buyer stats to better plan your upcoming sowing cycles.',
                            delay: 180,
                          ),
                        ] else if (isAdmin) ...[
                          _AboutCard(
                            icon: Icons.security_rounded,
                            iconColor: const Color(0xFF6D28D9),
                            title: 'Centralized Market Governance & RBAC',
                            content:
                                'HarvestHub implements robust Role-Based Access Control (RBAC) separating Customers, Farmers, and Administrators. Oversee accounts, ensure verified farm onboarding, and maintain catalog integrity.',
                            delay: 0,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.category_rounded,
                            iconColor: AppColors.primary,
                            title: 'Cloud-Synced Category Administration',
                            content:
                                'Manage crop taxonomies with live Cloud Firestore synchronization. Category changes reflect instantaneously in Customer search chips and Farmer product listing dropdowns without app redeployment.',
                            delay: 60,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.query_stats_rounded,
                            iconColor: AppColors.gold,
                            title: 'Platform GMV & Operational Oversight',
                            content:
                                'Monitor platform-wide Gross Merchandise Value (GMV), active transaction counts, registered farmer participation, and order fulfillment throughput from one executive dashboard.',
                            delay: 120,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.policy_rounded,
                            iconColor: AppColors.info,
                            title: 'SRS v1.4 Security & Compliance Standards',
                            content:
                                'Engineered strictly in compliance with HarvestHub SRS requirements, client-side AuthGuards, encrypted session storage, and server-side Firestore security rules.',
                            delay: 180,
                          ),
                        ] else ...[
                          _AboutCard(
                            icon: Icons.history_edu_rounded,
                            iconColor: AppColors.primary,
                            title: '1.1 Background & Agricultural Necessity',
                            content:
                                'Agriculture is the backbone of Pakistan\'s economy, employing over 38% of the workforce. However, small-scale growers face severe economic hurdles due to multi-tiered middlemen (Arthi system) and minimal direct consumer access.\n\nHarvestHub bridges this gap as a lightweight digital agricultural marketplace empowering growers and consumers with transparent direct trade.',
                            delay: 0,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.lightbulb_outline_rounded,
                            iconColor: AppColors.gold,
                            title: '1.2 Proposed Multi-Role Solution',
                            content:
                                'HarvestHub delivers dedicated operational interfaces for three core user groups:\n\n• Customers: Discover nearby farm produce, compare rates, and book local pickup slots.\n• Farmers: List crops, update stock quantities, fulfill orders, and generate revenue reports.\n• Administrators: Oversee system operations, maintain categories, and enforce trust & safety.',
                            delay: 60,
                          ),
                          const SizedBox(height: 14),
                          _AboutCard(
                            icon: Icons.smart_toy_rounded,
                            iconColor: AppColors.info,
                            title: 'Embedded AI Farm Assistant',
                            content:
                                'Integrated with an intelligent Agricultural Chatbot assisting users with crop storage guidelines, shelf-life tips, and seasonal produce advice.',
                            delay: 120,
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Team Badge
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primarySurface, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Team NK TECHNOVA',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Aptech TechWiz 7 — Multi-Platform App Computing',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 12),
                              const Text(
                                'Team Members',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _TeamMemberRow(name: 'Tuba Rabi', role: 'UI/UX Design & Flutter Development'),
                              const SizedBox(height: 6),
                              _TeamMemberRow(name: 'Abeer Waseem', role: 'Firebase Integration & Backend'),
                              const SizedBox(height: 6),
                              _TeamMemberRow(name: 'Muhammad Adil', role: 'Product Logic & State Management'),
                              const SizedBox(height: 6),
                              _TeamMemberRow(name: 'Abdul Rauf', role: 'Testing, Documentation & Deployment'),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 240.ms).slideY(begin: 0.04, end: 0),

                        const SizedBox(height: 14),

                        // Origin Badge
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HarvestHub eGreen Initiative',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Digitizing Local Farm Mandis • Faisalabad, Punjab, Pakistan',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.04, end: 0),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final int delay;

  const _AboutCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay)).slideY(begin: 0.04, end: 0);
  }
}

class _TeamMemberRow extends StatelessWidget {
  final String name;
  final String role;

  const _TeamMemberRow({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
