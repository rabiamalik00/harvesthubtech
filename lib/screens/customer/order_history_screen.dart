import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../../models/order_model.dart';
import '../../models/support_query_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';

class OrderHistoryScreen extends StatelessWidget {
  final bool showAppBar;
  const OrderHistoryScreen({super.key, this.showAppBar = true});

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return const Color(0xFFF4A261);
      case AppConstants.statusConfirmed:
        return const Color(0xFF2A9D8F);
      case AppConstants.statusReadyForPickup:
        return AppColors.accent;
      case AppConstants.statusCompleted:
        return AppColors.primary;
      case AppConstants.statusCancelled:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showModifySlotDialog(
      BuildContext context, OrderModel order, OrderProvider orderProvider) {
    final slots = [
      '08:00 AM - 10:00 AM',
      '10:00 AM - 12:00 PM',
      '02:00 PM - 04:00 PM',
      '04:00 PM - 06:00 PM',
    ];
    String selected = order.pickupSlotTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Modify Pickup Slot',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: slots
                .map((slot) => RadioListTile<String>(
                      value: slot,
                      groupValue: selected,
                      activeColor: AppColors.primary,
                      title: Text(slot,
                          style: TextStyle(
                              fontWeight: selected == slot
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13)),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selected = v);
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final ok = orderProvider.modifyOrderSlot(order.orderId, selected);
                Navigator.pop(ctx);
                showHarvestSnackBar(context,
                    message: ok
                        ? 'Pickup slot updated to: $selected'
                        : 'Could not modify slot.',
                    icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    backgroundColor: ok ? AppColors.primary : AppColors.danger);
              },
              child: const Text('Save Slot'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelOrder(
      BuildContext context, OrderModel order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order.orderId}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'This action will release your items and cancel the mandi pickup slot.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final ok = orderProvider.cancelOrder(order.orderId);
              Navigator.pop(ctx);
              showHarvestSnackBar(context,
                  message: ok
                      ? 'Order #${order.orderId} has been cancelled.'
                      : 'Cannot cancel this order.',
                  icon: Icons.info_outline_rounded,
                  backgroundColor: ok ? AppColors.danger : AppColors.warning);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // ─── Customer Review Dialog ─────────────────────────────────────────────────
  void _showReviewDialog(BuildContext context, OrderModel order) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    double rating = 5.0;
    final commentCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 8),
              Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farmer/Order info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.farmerBusinessName ?? 'Seller',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('Order #${order.orderId}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Your Rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                // Star rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starValue = i + 1.0;
                    return GestureDetector(
                      onTap: () => setS(() => rating = starValue),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          rating >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][rating.toInt()],
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Your Experience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: commentCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with the produce, freshness, and farmer...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      if (commentCtrl.text.trim().isEmpty) {
                        showHarvestSnackBar(context,
                            message: 'Please write your experience.',
                            icon: Icons.info_outline_rounded,
                            backgroundColor: AppColors.warning);
                        return;
                      }
                      setS(() => submitting = true);
                      final review = CustomerReviewModel(
                        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
                        customerName: user.name,
                        customerEmail: user.email,
                        targetFarmerOrMandi: order.farmerBusinessName ?? 'Seller',
                        rating: rating,
                        comment: commentCtrl.text.trim(),
                        createdAt: DateTime.now(),
                        verifiedPurchase: true,
                      );
                      await FirebaseService.saveCustomerReview(review);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        showHarvestSnackBar(context,
                            message: 'Review submitted! Thank you 🌾',
                            icon: Icons.star_rounded,
                            backgroundColor: AppColors.primary);
                      }
                    },
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final customerId = auth.currentUser?.uid ?? 'user_cust_1';
    final customerOrders = orderProvider.getCustomerOrders(customerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              leading: const AppBackButton(),
              title: const Text('Order History & Tracking'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: customerOrders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                              color: AppColors.primarySurface, shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long_rounded,
                              size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: 20),
                        const Text('No Orders Placed Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text(
                          'Your completed and pending farm produce pickups will appear here with real-time status tracking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                  itemCount: customerOrders.length,
                  itemBuilder: (context, index) {
                    final order = customerOrders[index];
                    final statusColor = _getStatusColor(order.status);
                    final formattedDate =
                        DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);
                    final canModify = order.status == AppConstants.statusPending;
                    final canCancel = order.status == AppConstants.statusPending ||
                        order.status == AppConstants.statusConfirmed;
                    final isCompleted = order.status == AppConstants.statusCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order ID and Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined,
                                        size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text('Order #${order.orderId}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: 6, height: 6,
                                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                      const SizedBox(width: 5),
                                      Text(order.status,
                                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(formattedDate,
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                            const SizedBox(height: 10),

                            // Pickup Slot
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text('Pickup Slot: ${order.pickupSlotTime}',
                                        style: const TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),

                            if (order.deliveryAddress.isNotEmpty &&
                                order.deliveryAddress != order.pickupSlotTime) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                      child: Text(order.deliveryAddress,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                                ],
                              ),
                            ],

                            const Divider(color: AppColors.cardBorder, height: 20),

                            // Items
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(item.displayTitle,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis)),
                                      Text('Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                )),

                            const Divider(color: AppColors.cardBorder, height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Items Subtotal:',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                                Text('Rs. ${order.itemsSubtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Platform Charges:',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                                Text('Rs. ${order.platformFee.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),

                            const Divider(color: AppColors.cardBorder, height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Price:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                                Text('Rs. ${order.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                              ],
                            ),

                            // Action Buttons
                            if (canModify || canCancel) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (canModify)
                                    Expanded(
                                      child: PressableScale(
                                        onPressed: () => _showModifySlotDialog(context, order, orderProvider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.primary),
                                              SizedBox(width: 6),
                                              Text('Modify Slot',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (canModify && canCancel) const SizedBox(width: 10),
                                  if (canCancel)
                                    Expanded(
                                      child: PressableScale(
                                        onPressed: () => _confirmCancelOrder(context, order, orderProvider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFFECACA)),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cancel_outlined, size: 14, color: AppColors.danger),
                                              SizedBox(width: 6),
                                              Text('Cancel Order',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],

                            // ★ Review button – visible for completed orders
                            if (isCompleted) ...[
                              const SizedBox(height: 12),
                              PressableScale(
                                onPressed: () => _showReviewDialog(context, order),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star_rounded, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text('Write a Review',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                ),
        ),
      ),
    );
  }
}
