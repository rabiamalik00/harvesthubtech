import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_toast.dart';

class OrderFulfillmentScreen extends StatelessWidget {
  const OrderFulfillmentScreen({super.key});

  final List<String> _statuses = const [
    AppConstants.statusPending,
    AppConstants.statusConfirmed,
    AppConstants.statusReadyForPickup,
    AppConstants.statusCompleted,
    AppConstants.statusCancelled,
  ];

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusCancelled:
        return AppColors.danger;
      case AppConstants.statusConfirmed:
        return AppColors.info;
      case AppConstants.statusReadyForPickup:
        return AppColors.gold;
      default:
        return AppColors.accent;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return Icons.check_circle_rounded;
      case AppConstants.statusCancelled:
        return Icons.cancel_rounded;
      case AppConstants.statusConfirmed:
        return Icons.thumb_up_rounded;
      case AppConstants.statusReadyForPickup:
        return Icons.shopping_bag_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final farmerId = auth.currentUser?.uid ?? 'farmer_1';
    final farmerOrders = orderProvider.getFarmerOrders(farmerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Fulfillment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: farmerOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 42, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Orders Received',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customer orders for your farm produce\nwill appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: farmerOrders.length,
              itemBuilder: (context, index) {
                final order = farmerOrders[index];
                final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);
                final statusColor = _statusColor(order.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.06),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_statusIcon(order.status), color: statusColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Order #${order.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const Spacer(),
                            Text(
                              order.customerName ?? 'Customer',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
                            ),
                          ],
                        ),
                      ),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date + Pickup slot
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textLight),
                                const SizedBox(width: 5),
                                Text(formattedDate, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 5),
                                Text(
                                  'Pickup: ${order.pickupSlotTime}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 10),

                            // Items
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${item.quantity} ${item.unit}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(item.cleanName, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                      ),
                                      Text(
                                        'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 8),
                            // Items subtotal + platform fee
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Items Subtotal', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('Rs. ${order.itemsSubtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Platform Charges', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('Rs. ${order.platformFee.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: AppColors.cardBorder),
                            const SizedBox(height: 12),

                            // Total + Status dropdown
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Revenue', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                    Text(
                                      'Rs. ${order.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Status Dropdown styled
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: order.status,
                                      isDense: true,
                                      icon: Icon(Icons.expand_more_rounded, color: statusColor, size: 18),
                                      items: _statuses
                                          .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(
                                                  s,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                    color: _statusColor(s),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          orderProvider.updateOrderStatus(order.orderId, newStatus);
                                          showHarvestSnackBar(
                                            context,
                                            message: 'Order #${order.orderId} → "$newStatus"',
                                            icon: Icons.check_circle_rounded,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 60)).slideY(begin: 0.04, end: 0);
              },
            ),
    );
  }
}
