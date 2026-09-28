import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app_config/constants.dart';
import '../../app_config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class AdminManageOrdersScreen extends StatefulWidget {
  const AdminManageOrdersScreen({super.key});

  @override
  State<AdminManageOrdersScreen> createState() =>
      _AdminManageOrdersScreenState();
}

class _AdminManageOrdersScreenState extends State<AdminManageOrdersScreen> {
  String _filterStatus = 'All';
  String _search = '';

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

  void _showOrderDetailsSheet(
      BuildContext context, OrderModel order, OrderProvider orderProvider) {
    final statuses = [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusReadyForPickup,
      AppConstants.statusCompleted,
      AppConstants.statusCancelled,
    ];
    String currentStatus = order.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final statusColor = _getStatusColor(currentStatus);
          final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a')
              .format(order.createdAt);

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              color: Colors.purple, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.orderId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                dateFormatted,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
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
                  const Divider(height: 1),

                  // Scrollable Details
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 18, color: statusColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Status: $currentStatus',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Customer Info Section
                          _sectionHeader(
                              'Customer & Delivery', Icons.person_outline),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              children: [
                                _detailRow('Customer Name',
                                    order.customerName ?? 'Customer'),
                                const Divider(height: 14),
                                _detailRow('Phone', order.buyerPhone),
                                const Divider(height: 14),
                                _detailRow(
                                    'Pickup / Delivery',
                                    order.deliveryAddress.isNotEmpty
                                        ? order.deliveryAddress
                                        : order.pickupSlotTime),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Farmer Info Section
                          _sectionHeader('Farmer / Producer', Icons.grass),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: _detailRow('Farm / Business',
                                order.farmerBusinessName ?? 'Bashir Green Organic Farms'),
                          ),
                          const SizedBox(height: 16),

                          // Ordered Items Section
                          _sectionHeader(
                              'Items (${order.items.length})', Icons.shopping_basket_outlined),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              children: [
                                ...order.items.map((item) => Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${item.quantity} ${item.unit} x ${item.itemName}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  '@ Rs. ${item.pricePerUnit.toStringAsFixed(0)}/${item.unit}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 16),
                                _detailRow('Items Subtotal',
                                    'Rs. ${order.itemsSubtotal.toStringAsFixed(0)}'),
                                const SizedBox(height: 4),
                                _detailRow('Platform Fee',
                                    'Rs. ${order.platformFee.toStringAsFixed(0)}'),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${order.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Status Update Options
                          _sectionHeader(
                              'Update Status', Icons.sync_alt_rounded),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: statuses.map((s) {
                              final isCurrent = currentStatus == s;
                              final c = _getStatusColor(s);
                              return ChoiceChip(
                                label: Text(s,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    )),
                                selected: isCurrent,
                                selectedColor: c.withValues(alpha: 0.18),
                                labelStyle: TextStyle(
                                  color: isCurrent ? c : AppColors.textPrimary,
                                ),
                                side: BorderSide(
                                  color: isCurrent ? c : AppColors.cardBorder,
                                  width: isCurrent ? 1.5 : 1,
                                ),
                                onSelected: (_) {
                                  setSheetState(() => currentStatus = s);
                                  orderProvider.updateOrderStatus(
                                      order.orderId, s);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Order #${order.orderId} updated to: $s'),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Close / Done Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.purple),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    var orders = orderProvider.orders;

    // Apply status filter
    if (_filterStatus != 'All') {
      orders = orders.where((o) => o.status == _filterStatus).toList();
    }

    // Apply search filter
    if (_search.isNotEmpty) {
      orders = orders
          .where((o) =>
              o.orderId.toLowerCase().contains(_search.toLowerCase()) ||
              (o.customerName ?? '')
                  .toLowerCase()
                  .contains(_search.toLowerCase()) ||
              (o.farmerBusinessName ?? '')
                  .toLowerCase()
                  .contains(_search.toLowerCase()))
          .toList();
    }

    // Platform reports using all users
    final reports = orderProvider.generatePlatformReports(auth.users);

    final filterStatuses = [
      'All',
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusReadyForPickup,
      AppConstants.statusCompleted,
      AppConstants.statusCancelled,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage All Orders'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Order ID, Customer, or Farmer...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Summary Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildStat('Total', '${reports['totalOrders']}', Colors.purple),
                const SizedBox(width: 6),
                _buildStat('Pending', '${reports['pendingOrders']}',
                    AppColors.warning),
                const SizedBox(width: 6),
                _buildStat('Completed', '${reports['completedOrders']}',
                    AppColors.success),
                const SizedBox(width: 6),
                _buildStat('Cancelled', '${reports['cancelledOrders'] ?? 0}',
                    AppColors.danger),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Status Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: filterStatuses
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s,
                              style: const TextStyle(fontSize: 11)),
                          selected: _filterStatus == s,
                          selectedColor: Colors.purple,
                          labelStyle: TextStyle(
                            color: _filterStatus == s
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: _filterStatus == s
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              setState(() => _filterStatus = s),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 60, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text('No orders found',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _getStatusColor(order.status);
                      final date = DateFormat('dd MMM yyyy, hh:mm a')
                          .format(order.createdAt);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showOrderDetailsSheet(
                              context, order, orderProvider),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row: ID and Status badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '#${order.orderId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            statusColor.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: statusColor, width: 0.8),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Customer & Farmer in fully expanded columns (NO OVERFLOW)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 13,
                                              color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              order.customerName ?? 'Customer',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.grass,
                                              size: 13,
                                              color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              order.farmerBusinessName ?? 'Farmer',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Items summary
                                Text(
                                  '${order.items.length} item(s): ${order.items.map((i) => i.itemName).join(', ')}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                                // Bottom Row: Price & Details button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs. ${order.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.purple.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.touch_app_outlined,
                                              size: 13, color: Colors.purple),
                                          SizedBox(width: 4),
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple,
                                            ),
                                          ),
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
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
