import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_toast.dart';
import 'admin_manage_orders_screen.dart';

class PlatformReportsScreen extends StatelessWidget {
  const PlatformReportsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return AppColors.warning;
      case AppConstants.statusConfirmed:
        return AppColors.info;
      case AppConstants.statusReadyForPickup:
        return AppColors.accent;
      case AppConstants.statusCompleted:
        return AppColors.success;
      case AppConstants.statusCancelled:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  // 1. GMV & Revenue Drill-down
  void _showGmvBreakdownSheet(
    BuildContext context,
    OrderProvider orderProvider,
    Map<String, dynamic> reports,
  ) {
    final allOrders = orderProvider.orders;
    final completedOrders = allOrders.where((o) => o.status == AppConstants.statusCompleted).toList();
    final pendingOrders = allOrders.where((o) => o.status != AppConstants.statusCompleted && o.status != AppConstants.statusCancelled).toList();
    final double gmv = reports['totalRevenue'] as double;
    final double completedRevenue = completedOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final double pendingRevenue = pendingOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final double avgOrder = allOrders.isNotEmpty ? (gmv / allOrders.length) : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.payments_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform GMV & Financial Audit',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Live revenue breakdown from all farm transactions',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Summary Cards Row
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSmallStatCard(
                          'Realized GMV',
                          'Rs. ${completedRevenue.toStringAsFixed(0)}',
                          AppColors.success,
                          Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallStatCard(
                          'In-Pipeline',
                          'Rs. ${pendingRevenue.toStringAsFixed(0)}',
                          AppColors.warning,
                          Icons.hourglass_top_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSmallStatCard(
                          'Avg Order',
                          'Rs. ${avgOrder.toStringAsFixed(0)}',
                          AppColors.primary,
                          Icons.show_chart_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All Contributing Orders (${allOrders.length})',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                Expanded(
                  child: allOrders.isEmpty
                      ? const Center(child: Text('No orders placed yet.'))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: allOrders.length,
                          itemBuilder: (context, idx) {
                            final o = allOrders[idx];
                            final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(o.createdAt);
                            final color = _getStatusColor(o.status);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.receipt_long_rounded, color: color, size: 20),
                                ),
                                title: Text(
                                  'Order #${o.orderId.substring(0, o.orderId.length > 8 ? 8 : o.orderId.length)}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Customer ID: ${o.customerId} • $dateStr', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text('Pickup Slot: ${o.pickupSlot}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs. ${o.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        o.status,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
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
            ),
          );
        },
      ),
    );
  }

  // 2. Completed Orders Drill-down
  void _showCompletedOrdersSheet(BuildContext context, OrderProvider orderProvider) {
    final completed = orderProvider.orders.where((o) => o.status == AppConstants.statusCompleted).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed Orders (${completed.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            const Text(
                              'Produce successfully collected by customers & paid in cash',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: completed.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No completed orders yet. Orders will appear here once farmers mark them completed upon pickup.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: completed.length,
                          itemBuilder: (context, idx) {
                            final o = completed[idx];
                            final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(o.createdAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${o.orderId.substring(0, o.orderId.length > 8 ? 8 : o.orderId.length)}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5EE),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, color: AppColors.success, size: 14),
                                              SizedBox(width: 4),
                                              Text('Completed', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Customer ID: ${o.customerId}  •  Farmer ID: ${o.farmerId}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('Date: $dateStr', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                    Text('Pickup Slot: ${o.pickupSlot}', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    const Divider(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${o.items.length} items purchased', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        Text(
                                          'Total: Rs. ${o.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ],
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
  }

  // 3. Active Farmers with Orders Drill-down
  void _showActiveFarmersSheet(
    BuildContext context,
    OrderProvider orderProvider,
    AuthProvider auth,
  ) {
    final orders = orderProvider.orders;
    // Map farmerId -> orders
    final Map<String, List<OrderModel>> farmerOrders = {};
    for (final o in orders) {
      farmerOrders.putIfAbsent(o.farmerId, () => []).add(o);
    }

    final farmersList = auth.users.where((u) => u.isFarmer).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.grass_rounded, color: Colors.green, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Farmers With Orders (${farmerOrders.keys.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            const Text(
                              'Farmers currently fulfilling customer pickup orders',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: farmerOrders.isEmpty
                      ? const Center(
                          child: Text('No farmers currently have active orders.'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: farmerOrders.keys.length,
                          itemBuilder: (context, idx) {
                            final farmerId = farmerOrders.keys.elementAt(idx);
                            final fOrders = farmerOrders[farmerId]!;
                            final farmerUser = farmersList.firstWhere(
                              (u) => u.uid == farmerId,
                              orElse: () => UserModel(
                                uid: farmerId,
                                name: 'Farm Producer #$farmerId',
                                email: 'farmer@harvesthub.com',
                                phone: '+92 300 0000000',
                                role: AppConstants.roleFarmer,
                                createdAt: DateTime.now(),
                              ),
                            );

                            final double totalSales = fOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
                            final int pendingCount = fOrders.where((o) => o.status == AppConstants.statusPending).length;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primarySurface,
                                      child: const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            farmerUser.name,
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            farmerUser.email,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          Text(
                                            'Phone: ${farmerUser.phone}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primarySurface,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${fOrders.length} Order(s)',
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                ),
                                              ),
                                              if (pendingCount > 0)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFF3ED),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '$pendingCount Pending',
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                                                  ),
                                                ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5EE),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Rs. ${totalSales.toStringAsFixed(0)} Vol',
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                                ),
                                              ),
                                            ],
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
            ),
          );
        },
      ),
    );
  }

  // 4. Registered Farmers Directory Drill-down
  void _showRegisteredFarmersSheet(BuildContext context, AuthProvider auth) {
    final farmers = auth.users.where((u) => u.isFarmer).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered Farmers (${farmers.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            const Text(
                              'All verified local agricultural producers on HarvestHub',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: farmers.isEmpty
                      ? const Center(child: Text('No farmers registered yet.'))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: farmers.length,
                          itemBuilder: (context, idx) {
                            final f = farmers[idx];
                            final dateStr = DateFormat('dd MMM yyyy').format(f.createdAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primarySurface,
                                  child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                                ),
                                title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Text('Email: ${f.email}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('Phone: ${f.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                    if (f.address.isNotEmpty)
                                      Text('Farm: ${f.address}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                                    Text('Registered: $dateStr', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                  tooltip: 'Remove Farmer',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('Remove Farmer?'),
                                        content: Text('Are you sure you want to remove ${f.name} from the platform?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dCtx);
                                              auth.deleteUser(f.uid);
                                              if (context.mounted) {
                                                showHarvestSnackBar(context, message: 'Farmer removed from platform.');
                                              }
                                            },
                                            child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
  }

  // 5. Registered Customers Directory Drill-down
  void _showRegisteredCustomersSheet(BuildContext context, AuthProvider auth) {
    final customers = auth.users.where((u) => u.isCustomer).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildSheetHandle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.people_rounded, color: AppColors.accent, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered Customers (${customers.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            const Text(
                              'Consumers purchasing fresh produce from local farmers',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: customers.isEmpty
                      ? const Center(child: Text('No customers registered yet.'))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: customers.length,
                          itemBuilder: (context, idx) {
                            final c = customers[idx];
                            final dateStr = DateFormat('dd MMM yyyy').format(c.createdAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFFFF0E6),
                                  child: const Icon(Icons.person_rounded, color: AppColors.accent, size: 24),
                                ),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Text('Email: ${c.email}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('Phone: ${c.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                    if (c.address.isNotEmpty)
                                      Text('Address: ${c.address}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                                    Text('Joined: $dateStr', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                  tooltip: 'Remove Customer',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('Remove Customer?'),
                                        content: Text('Are you sure you want to remove customer ${c.name}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dCtx);
                                              auth.deleteUser(c.uid);
                                              if (context.mounted) {
                                                showHarvestSnackBar(context, message: 'Customer account removed.');
                                              }
                                            },
                                            child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
  }

  // 6. Mandi Markets Drill-down
  void _showMandiMarketsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                _buildSheetHandle(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Operational Mandi Markets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          Text('Designated collection points for simulated pickup slots', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(height: 24),
                // Market 1
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Faisalabad Model Mandi Market',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Operational 🟢', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('📍 Location: Main Canal Road, Near Jhal Bridge, Faisalabad', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('⏰ Operating Hours: 08:00 AM – 06:00 PM (Mon–Sat)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('☎️ Helpdesk: +92 41 9200100', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPill('Direct Farmer Stalls'),
                            _buildPill('Cold Storage Facility'),
                            _buildPill('Weigh Station'),
                            _buildPill('Simulated Pickup Bay'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Market 2
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Lahore Model Agriculture Bazaar',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Operational 🟢', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('📍 Location: Johar Town Commercial Complex, Lahore', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('⏰ Operating Hours: 07:00 AM – 07:00 PM (Daily)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('☎️ Helpdesk: +92 42 99230000', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPill('Organic produce lane'),
                            _buildPill('Covered shed'),
                            _buildPill('Quality testing lab'),
                            _buildPill('Easy parking'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Widget _buildSmallStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  static Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }

  void _showEditPlatformFeeDialog(BuildContext context, OrderProvider orderProvider) {
    final controller = TextEditingController(text: orderProvider.platformFee.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Set Platform Charges',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Fee Governance',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure the standard per-order platform fee applied during checkout.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Platform Fee (Rs.)',
                  prefixText: 'Rs. ',
                  prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter a fee amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newFee = double.parse(controller.text.trim());
                await orderProvider.setPlatformFee(newFee);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  showHarvestSnackBar(
                    context,
                    message: 'Platform charges updated to Rs. ${newFee.toStringAsFixed(0)}',
                    icon: Icons.check_circle_rounded,
                  );
                }
              }
            },
            child: const Text('Save Fee', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final reports = orderProvider.generatePlatformReports(auth.users);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Platform Analytics & Reports', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: const Color(0xFF1E6F5C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Platform Revenue & Order Metrics',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),

                // Admin Platform Charges Control Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.price_change_rounded, color: Color(0xFF7C3AED), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Platform Charges (Admin Control)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Current per-order fee: Rs. ${orderProvider.platformFee.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showEditPlatformFeeDialog(context, orderProvider),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit Fee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Row 1: GMV & Total Orders
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Total Platform GMV',
                        value: 'Rs. ${(reports['totalRevenue'] as double).toStringAsFixed(0)}',
                        icon: Icons.payments_rounded,
                        color: AppColors.primary,
                        onTap: () => _showGmvBreakdownSheet(context, orderProvider, reports),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Total Orders',
                        value: '${reports['totalOrders']}',
                        icon: Icons.shopping_cart_rounded,
                        color: AppColors.accent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminManageOrdersScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Active Farmers & Completed Orders
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Active Farmers',
                        value: '${reports['activeFarmersCount']} Growers',
                        icon: Icons.grass_rounded,
                        color: Colors.green,
                        onTap: () => _showActiveFarmersSheet(context, orderProvider, auth),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Completed Orders',
                        value: '${reports['completedOrders']}',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.info,
                        onTap: () => _showCompletedOrdersSheet(context, orderProvider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: Registered Farmers & Registered Customers
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Registered Farmers',
                        value: '${reports['totalRegisteredFarmers'] ?? 0}',
                        icon: Icons.agriculture_rounded,
                        color: AppColors.primary,
                        onTap: () => _showRegisteredFarmersSheet(context, auth),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Registered Customers',
                        value: '${reports['totalRegisteredCustomers'] ?? 0}',
                        icon: Icons.people_rounded,
                        color: AppColors.accent,
                        onTap: () => _showRegisteredCustomersSheet(context, auth),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Mandi Markets Overview (Clickable)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showMandiMarketsSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Active Mandi Markets Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('1. Faisalabad Model Mandi Market (Main Canal Road)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const Text('   Active Status: 🟢 Operational • Operating Hours: 08:00 AM - 06:00 PM', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          const Text('2. Lahore Model Agriculture Bazaar (Johar Town Complex)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const Text('   Active Status: 🟢 Operational • Operating Hours: 07:00 AM - 07:00 PM', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
