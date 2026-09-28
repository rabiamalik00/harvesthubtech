import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/quick_action_icon.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';
import '../common/about_us_screen.dart';
import '../common/contact_us_screen.dart';
import '../common/login_screen.dart';
import '../common/profile_screen.dart';
import 'ai_assistant_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'product_browsing_screen.dart';
import 'wishlist_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % 4;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showNotificationDetailDialog(
    BuildContext parentContext,
    Map<String, dynamic> notif,
    VoidCallback onCloseNotificationSheet,
  ) {
    final isRestock = notif['type'] == 'restock';
    final isOrder = notif['type'] == 'order';

    final Color badgeBg = isRestock
        ? const Color(0xFFFFF3ED)
        : (isOrder ? AppColors.primarySurface : const Color(0xFFE0F2FE));
    final Color badgeColor = isRestock
        ? AppColors.accent
        : (isOrder ? AppColors.primary : Colors.blue.shade700);
    final IconData badgeIcon = isRestock
        ? Icons.notifications_active_rounded
        : (isOrder ? Icons.local_shipping_rounded : Icons.grass_rounded);
    final String typeLabel = isRestock
        ? 'Restock Alert'
        : (isOrder ? 'Order Tracking Update' : 'Welcome Announcement');

    showDialog(
      context: parentContext,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header with icon, category badge, and close button
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(badgeIcon, color: badgeColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textLight),
                              const SizedBox(width: 4),
                              Text(
                                notif['time'] ?? 'Recently',
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textLight, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 14),

                // Title
                Text(
                  notif['title'] ?? 'Notification',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Full Message in a styled card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    notif['message'] ?? '',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contextual Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: Icon(
                          isOrder
                              ? Icons.local_shipping_rounded
                              : (isRestock ? Icons.storefront_rounded : Icons.explore_rounded),
                          size: 18,
                        ),
                        label: Text(
                          isOrder
                              ? 'View My Orders'
                              : (isRestock ? 'Browse Harvest' : 'Explore Market'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx); // Close dialog
                          onCloseNotificationSheet(); // Close bottom sheet
                          if (isOrder) {
                            setState(() => _currentIndex = 3); // Track Orders tab
                          } else {
                            setState(() => _currentIndex = 0); // Market tab
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context, ProductProvider pp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<ProductProvider>(
          builder: (context, productProv, _) {
            final notifs = productProv.inAppNotifications;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.65,
                maxChildSize: 0.88,
                minChildSize: 0.4,
                expand: false,
                builder: (_, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Alerts & Notifications',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (productProv.unreadNotificationCount > 0)
                              InkWell(
                                onTap: () => productProv.markNotificationsRead(),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text(
                                    'Mark all read',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ),
                            if (notifs.isNotEmpty)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (val) {
                                  if (val == 'read_all') {
                                    productProv.markNotificationsRead();
                                  } else if (val == 'clear_all') {
                                    productProv.clearAllNotifications();
                                  }
                                },
                                itemBuilder: (popCtx) => [
                                  if (productProv.unreadNotificationCount > 0)
                                    const PopupMenuItem(
                                      value: 'read_all',
                                      child: Row(
                                        children: [
                                          Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
                                          SizedBox(width: 8),
                                          Text('Mark all as read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'clear_all',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.danger),
                                        SizedBox(width: 8),
                                        Text(
                                          'Clear all notifications',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.danger),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: AppColors.cardBorder),
                        Expanded(
                          child: notifs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primarySurface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.notifications_none_rounded, size: 36, color: AppColors.primaryLight),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No notifications yet',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Restock & order tracking alerts will appear here',
                                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  itemCount: notifs.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
                                  itemBuilder: (context, i) {
                                    final n = notifs[i];
                                    final isRestock = n['type'] == 'restock';
                                    final isOrder = n['type'] == 'order';
                                    final isRead = n['read'] == true;

                                    return Dismissible(
                                      key: Key('notif_${n['id'] ?? i}'),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 18),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                      ),
                                      onDismissed: (_) {
                                        productProv.deleteNotification(i);
                                      },
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () {
                                          n['read'] = true;
                                          productProv.markNotificationsRead();
                                          _showNotificationDetailDialog(
                                            context,
                                            n,
                                            () => Navigator.pop(ctx),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: !isRead ? AppColors.primarySurface.withValues(alpha: 0.35) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: isRestock
                                                    ? const Color(0xFFFFF3ED)
                                                    : (isOrder ? AppColors.primarySurface : const Color(0xFFE0F2FE)),
                                                child: Icon(
                                                  isRestock
                                                      ? Icons.notifications_active_rounded
                                                      : (isOrder ? Icons.local_shipping_rounded : Icons.grass_rounded),
                                                  color: isRestock
                                                      ? AppColors.accent
                                                      : (isOrder ? AppColors.primary : Colors.blue.shade700),
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            n['title'] ?? '',
                                                            style: TextStyle(
                                                              fontWeight: !isRead ? FontWeight.w800 : FontWeight.w600,
                                                              fontSize: 13,
                                                              color: AppColors.textPrimary,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        if (!isRead)
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            margin: const EdgeInsets.only(left: 6),
                                                            decoration: const BoxDecoration(
                                                              color: AppColors.accent,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      n['message'] ?? '',
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textLight),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          n['time'] ?? '',
                                                          style: const TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500),
                                                        ),
                                                        const Spacer(),
                                                        const Text(
                                                          'Tap to view details',
                                                          style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
                                                        ),
                                                        const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textLight),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onSelected: (val) {
                                                  if (val == 'view') {
                                                    n['read'] = true;
                                                    productProv.markNotificationsRead();
                                                    _showNotificationDetailDialog(
                                                      context,
                                                      n,
                                                      () => Navigator.pop(ctx),
                                                    );
                                                  } else if (val == 'delete') {
                                                    productProv.deleteNotification(i);
                                                  } else if (val == 'read') {
                                                    n['read'] = true;
                                                    productProv.markNotificationsRead();
                                                  }
                                                },
                                                itemBuilder: (menuCtx) => [
                                                  const PopupMenuItem(
                                                    value: 'view',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.visibility_outlined, size: 17, color: AppColors.primary),
                                                        SizedBox(width: 8),
                                                        Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!isRead)
                                                    const PopupMenuItem(
                                                      value: 'read',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.check_circle_outline_rounded, size: 17, color: AppColors.primary),
                                                          SizedBox(width: 8),
                                                          Text('Mark as read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                    ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.danger),
                                                        SizedBox(width: 8),
                                                        Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.danger)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGreetingHeader(BuildContext context, String userName, ProductProvider pp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Healthy crops, happy farmers!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Notification bell with restock badge
              PressableScale(
                onPressed: () => _showNotificationsDialog(context, pp),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
                      if (pp.unreadNotificationCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // User Avatar
              PressableScale(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSliderWidget(BuildContext context, ProductProvider pp) {
    final slides = [
      // Slide 1: Weather & Crop Advisory
      _PromoSlide(
        gradientColors: const [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        tag: "Today's Weather • ${pp.userCity}",
        tagIcon: Icons.wb_sunny_rounded,
        tagColor: const Color(0xFFF4A261),
        titleRow: const Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '28°C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Sunny & Clear',
              style: TextStyle(
                color: Color(0xFFD8F3DC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        subtitle: 'Optimal harvesting conditions across Punjab mandis',
        trailingIcon: Icons.agriculture_rounded,
      ),

      // Slide 2: Direct Mandi Savings
      _PromoSlide(
        gradientColors: const [Color(0xFF7C2D12), Color(0xFFC2410C)],
        tag: '100% Farm Fresh Guarantee',
        tagIcon: Icons.verified_rounded,
        tagColor: const Color(0xFFFFD166),
        titleRow: const Text(
          'Save Up To 25%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        subtitle: 'Direct from verified Punjab farmers • Zero middlemen',
        trailingIcon: Icons.storefront_rounded,
        onTap: () => pp.setCategory('All'),
      ),

      // Slide 3: Seasonal Crop Highlight
      _PromoSlide(
        gradientColors: const [Color(0xFF854D0E), Color(0xFFD97706)],
        tag: 'Seasonal Harvest Spotlight',
        tagIcon: Icons.eco_rounded,
        tagColor: const Color(0xFFFEF08A),
        titleRow: const Text(
          'Kinnow Season Live',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        subtitle: 'Freshly plucked Sargodha citrus in local mandis',
        trailingIcon: Icons.shopping_basket_rounded,
        onTap: () => pp.setCategory('Fruits'),
      ),

      // Slide 4: AI Farm Assistant
      _PromoSlide(
        gradientColors: const [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        tag: '24/7 AI Farm Assistant',
        tagIcon: Icons.smart_toy_rounded,
        tagColor: const Color(0xFF93C5FD),
        titleRow: const Text(
          'Instant Crop Advisories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        subtitle: 'Ask about nutrition facts, crop preservation & storage',
        trailingIcon: Icons.chat_bubble_outline_rounded,
        onTap: () => setState(() => _currentIndex = 4),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          Container(
            height: 136,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _bannerController,
                  onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
                  itemCount: slides.length,
                  itemBuilder: (_, i) => slides[i],
                ),
                // Indicator dots
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (idx) {
                      final isActive = idx == _currentBannerIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 6,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: QuickActionIcon(
              icon: Icons.grass_rounded,
              label: 'Wheat & Crops',
              bgColor: const Color(0xFFFFF3ED),
              iconColor: AppColors.accent,
              onTap: () {
                Provider.of<ProductProvider>(context, listen: false).setCategory('Grains');
              },
            ),
          ),
          Expanded(
            child: QuickActionIcon(
              icon: Icons.trending_up_rounded,
              label: 'Market Rates',
              bgColor: AppColors.primarySurface,
              iconColor: AppColors.primary,
              onTap: () {
                Provider.of<ProductProvider>(context, listen: false).setSortByNearest(true);
              },
            ),
          ),
          Expanded(
            child: QuickActionIcon(
              icon: Icons.smart_toy_rounded,
              label: 'AI Advisor',
              bgColor: const Color(0xFFE8F0FE),
              iconColor: Colors.blue.shade700,
              onTap: () => setState(() => _currentIndex = 4),
            ),
          ),
          Expanded(
            child: QuickActionIcon(
              icon: Icons.receipt_long_rounded,
              label: 'My Orders',
              bgColor: const Color(0xFFFEF3C7),
              iconColor: Colors.amber.shade800,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCarousel(BuildContext context, ProductProvider pp) {
    final products = pp.products;
    if (products.isEmpty) return const SizedBox.shrink();

    final recommended = products.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => pp.setCategory('All'),
                child: const Text(
                  'See All →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final prod = recommended[i];
              return PressableScale(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: prod),
                    ),
                  );
                },
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            HarvestImage(
                              imageUrl: prod.imageUrl,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.eco,
                            ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  prod.category,
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.itemName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rs. ${prod.pricePerUnit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHomeView(BuildContext context, String userName, ProductProvider pp) {
    return ProductBrowsingScreen(
      headerWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingHeader(context, userName, pp),
          _buildPromoSliderWidget(context, pp),
          _buildQuickActionRow(context),
          _buildRecommendedCarousel(context, pp),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final user = auth.currentUser;
    final userName = user?.name ?? 'Farmer Partner';

    final pages = [
      _buildHomeView(context, userName, productProvider),
      const WishlistScreen(showAppBar: true),
      const CartScreen(showAppBar: true),
      const OrderHistoryScreen(showAppBar: true),
      const AiAssistantScreen(showAppBar: true),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(context, user, auth, cart),
        body: SafeArea(
          bottom: false,
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: AppColors.background,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: pages[_currentIndex],
            ),
          ),
        ),
        bottomNavigationBar: FloatingBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const FloatingNavItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront_rounded,
              label: 'Market',
            ),
            FloatingNavItem(
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite_rounded,
              label: 'Wishlist',
              badgeCount: productProvider.wishlistProductIds.length,
            ),
            FloatingNavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag_rounded,
              label: 'Cart',
              badgeCount: cart.itemCount,
            ),
            const FloatingNavItem(
              icon: Icons.history_rounded,
              activeIcon: Icons.history_rounded,
              label: 'Orders',
            ),
            const FloatingNavItem(
              icon: Icons.smart_toy_outlined,
              activeIcon: Icons.smart_toy_rounded,
              label: 'AI Bot',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user, AuthProvider auth, CartProvider cart) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name != null && user!.name.isNotEmpty) ? user!.name[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'HarvestHub Member',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'customer@harvesthub.com',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFD8F3DC)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Verified Buyer', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(
            icon: Icons.storefront_rounded,
            title: 'Browse Marketplace',
            isSelected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          _drawerItem(
            icon: Icons.favorite_rounded,
            title: 'My Wishlist',
            isSelected: _currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          _drawerItem(
            icon: Icons.shopping_bag_rounded,
            title: 'Shopping Cart',
            badge: cart.itemCount > 0 ? '${cart.itemCount}' : null,
            isSelected: _currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          _drawerItem(
            icon: Icons.local_shipping_rounded,
            title: 'Track Orders',
            isSelected: _currentIndex == 3,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
          _drawerItem(
            icon: Icons.smart_toy_rounded,
            title: 'AI Farm Advisor',
            isSelected: _currentIndex == 4,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: AppColors.cardBorder),
          ),
          _drawerItem(
            icon: Icons.person_outline_rounded,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          _drawerItem(
            icon: Icons.info_outline_rounded,
            title: 'About HarvestHub',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen(role: 'customer')));
            },
          ),
          _drawerItem(
            icon: Icons.headset_mic_outlined,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen(role: 'customer')));
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PressableScale(
              onPressed: () {
                Navigator.pop(context);
                auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    String? badge,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : const Color(0xFFF6FAF6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _PromoSlide extends StatelessWidget {
  final List<Color> gradientColors;
  final String tag;
  final IconData tagIcon;
  final Color tagColor;
  final Widget titleRow;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const _PromoSlide({
    required this.gradientColors,
    required this.tag,
    required this.tagIcon,
    required this.tagColor,
    required this.titleRow,
    required this.subtitle,
    required this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Watermark icon
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  trailingIcon,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tagIcon, color: tagColor, size: 13),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    tag,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          titleRow,
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trailingIcon,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

