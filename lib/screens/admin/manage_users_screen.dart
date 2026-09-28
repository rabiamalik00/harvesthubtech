import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../app_config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';

const _adminPrimary = Color(0xFF5B21B6);

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedRoleFilter = 'All'; // 'All' | 'Farmer' | 'Customer'
  String _searchQuery = '';
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(AuthProvider auth) async {
    setState(() => _isRefreshing = true);
    await auth.refreshUsers();
    if (mounted) {
      setState(() => _isRefreshing = false);
      showHarvestSnackBar(
        context,
        message: 'User list updated from cloud database.',
        icon: Icons.sync_rounded,
        backgroundColor: _adminPrimary,
      );
    }
  }

  void _confirmDeleteUser(BuildContext context, AuthProvider auth, UserModel user) {
    if (user.isAdmin || user.email.toLowerCase() == 'admin@harvesthub.com') {
      showHarvestSnackBar(
        context,
        message: 'The Platform Administrator account cannot be deleted.',
        icon: Icons.shield_rounded,
        backgroundColor: Colors.amber.shade900,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete User Account?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${user.name}? This will remove their credentials and revoke platform access.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: user.isFarmer ? AppColors.primarySurface : const Color(0xFFE0F2FE),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.isFarmer ? AppColors.primary : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await auth.deleteUser(user.uid);
              if (context.mounted) {
                showHarvestSnackBar(
                  context,
                  message: 'User account ${user.name} removed successfully.',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: AppColors.success,
                );
              }
            },
            child: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsModal(BuildContext context, UserModel user, int productCount, int orderCount) {
    final dateFormat = DateFormat('dd MMMM yyyy, hh:mm a');
    final formattedDate = dateFormat.format(user.createdAt);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header with Avatar & Role Badge
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: user.isFarmer
                          ? AppColors.primarySurface
                          : (user.isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user.isFarmer
                            ? AppColors.primary
                            : (user.isAdmin ? _adminPrimary : Colors.blue.shade700),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: user.isFarmer
                              ? AppColors.primary
                              : (user.isAdmin ? _adminPrimary : Colors.blue.shade700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, size: 18, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: user.isFarmer
                                    ? AppColors.primarySurface
                                    : (user.isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: user.isFarmer
                                      ? AppColors.primary
                                      : (user.isAdmin ? _adminPrimary : Colors.blue.shade700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: AppColors.textLight)),
                            const SizedBox(width: 8),
                            const Text(
                              'Verified Account',
                              style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textLight),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 14),

              // UID Card with Copy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'UID: ${user.uid}',
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.uid));
                        showHarvestSnackBar(context, message: 'UID copied to clipboard.');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail Tiles
              _buildDetailItem(
                icon: Icons.mail_outline_rounded,
                iconColor: Colors.deepPurple,
                title: 'Email Address',
                value: user.email,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: user.email));
                  showHarvestSnackBar(context, message: 'Email copied to clipboard.');
                },
              ),
              const SizedBox(height: 10),
              _buildDetailItem(
                icon: Icons.phone_outlined,
                iconColor: AppColors.primary,
                title: 'Mobile Phone',
                value: user.phone.isNotEmpty ? user.phone : 'Not provided',
                onCopy: user.phone.isNotEmpty
                    ? () {
                        Clipboard.setData(ClipboardData(text: user.phone));
                        showHarvestSnackBar(context, message: 'Phone copied to clipboard.');
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              _buildDetailItem(
                icon: Icons.calendar_today_rounded,
                iconColor: Colors.orange.shade800,
                title: 'Registration Date',
                value: formattedDate,
              ),
              const SizedBox(height: 10),

              // Role Specific Details
              if (user.isFarmer) ...[
                _buildDetailItem(
                  icon: Icons.agriculture_rounded,
                  iconColor: AppColors.primary,
                  title: 'Farm / Business Name',
                  value: user.farmName?.isNotEmpty == true ? user.farmName! : 'Direct Local Grower',
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  icon: Icons.storefront_rounded,
                  iconColor: Colors.teal,
                  title: 'Assigned Model Mandi / Market',
                  value: user.marketName?.isNotEmpty == true ? user.marketName! : 'Faisalabad Model Mandi',
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.redAccent,
                  title: 'Farm Location / Address',
                  value: user.address.isNotEmpty ? user.address : 'Punjab Agricultural Belt',
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.indigo,
                  title: 'Active Products Listed',
                  value: '$productCount products currently in catalog',
                ),
              ] else if (user.isCustomer) ...[
                _buildDetailItem(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.redAccent,
                  title: 'Default Delivery Address',
                  value: user.address.isNotEmpty ? user.address : 'Standard Pickup from Mandi Hub',
                ),
                const SizedBox(height: 10),
                _buildDetailItem(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppColors.accent,
                  title: 'Orders Placed on Platform',
                  value: '$orderCount total orders recorded',
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close'),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ),
                  if (!user.isAdmin) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: AppColors.danger,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete User', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          _confirmDeleteUser(context, auth, user);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textLight),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final allUsers = auth.users;
    final farmerCount = allUsers.where((u) => u.isFarmer).length;
    final customerCount = allUsers.where((u) => u.isCustomer).length;

    // Filter by role and search query
    final filteredUsers = allUsers.where((u) {
      if (_selectedRoleFilter == 'Farmer' && !u.isFarmer) return false;
      if (_selectedRoleFilter == 'Customer' && !u.isCustomer) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = u.name.toLowerCase().contains(q);
        final matchesEmail = u.email.toLowerCase().contains(q);
        final matchesPhone = u.phone.toLowerCase().contains(q);
        final matchesFarm = u.farmName?.toLowerCase().contains(q) ?? false;
        final matchesMarket = u.marketName?.toLowerCase().contains(q) ?? false;
        final matchesAddress = u.address.toLowerCase().contains(q);
        return matchesName || matchesEmail || matchesPhone || matchesFarm || matchesMarket || matchesAddress;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _adminPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Customers & Farmers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync_rounded),
            tooltip: 'Sync Users from Cloud',
            onPressed: () => _handleRefresh(auth),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(auth),
        color: _adminPrimary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Top Overview Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Total Users',
                    count: '${allUsers.length}',
                    icon: Icons.people_alt_rounded,
                    color: _adminPrimary,
                    bg: const Color(0xFFF3E8FF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Farmers',
                    count: '$farmerCount',
                    icon: Icons.agriculture_rounded,
                    color: AppColors.primary,
                    bg: AppColors.primarySurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Customers',
                    count: '$customerCount',
                    icon: Icons.shopping_basket_rounded,
                    color: Colors.blue.shade700,
                    bg: const Color(0xFFE0F2FE),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 250.ms),

            const SizedBox(height: 16),

            // Live Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: _adminPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Search registered user, email, farm, mandi...',
                        hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textLight),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 14),

            // Role Filter Segment Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'All Users (${allUsers.length})', Icons.group_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Farmer', 'Farmers ($farmerCount)', Icons.agriculture_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Customer', 'Customers ($customerCount)', Icons.shopping_bag_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Users (${filteredUsers.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap for details',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Users List
            if (filteredUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_search_rounded, size: 36, color: _adminPrimary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No matching users found',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Try adjusting your search query or role filter tab.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...filteredUsers.asMap().entries.map((entry) {
                final idx = entry.key;
                final u = entry.value;

                final farmerProductsCount = productProvider.products.where((p) => p.farmerId == u.uid).length;
                final customerOrdersCount = orderProvider.orders.where((o) => o.customerId == u.uid).length;

                final isFarmer = u.isFarmer;
                final isAdmin = u.isAdmin;
                final Color roleColor = isFarmer ? AppColors.primary : (isAdmin ? _adminPrimary : Colors.blue.shade700);
                final Color roleBg = isFarmer
                    ? AppColors.primarySurface
                    : (isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showUserDetailsModal(context, u, farmerProductsCount, customerOrdersCount),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Avatar + Name + Role Badge + Options
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: roleBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: roleColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            u.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified_rounded, size: 15, color: Colors.blue),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      u.email,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: roleBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: roleColor.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  u.role,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: roleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          const SizedBox(height: 10),

                          // Metadata row: Phone & Specific info
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                u.phone.isNotEmpty ? u.phone : 'No phone',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 12),
                              if (isFarmer && u.farmName?.isNotEmpty == true) ...[
                                const Icon(Icons.agriculture_rounded, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    u.farmName!,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else if (isFarmer && u.marketName?.isNotEmpty == true) ...[
                                const Icon(Icons.storefront_rounded, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    u.marketName!,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else if (u.address.isNotEmpty) ...[
                                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    u.address,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                const Spacer(),
                              ],
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Bottom Action Strip
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, size: 12, color: AppColors.textLight),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(u.createdAt),
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.textLight, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              PressableScale(
                                onPressed: () => _showUserDetailsModal(context, u, farmerProductsCount, customerOrdersCount),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 13, color: AppColors.textPrimary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Details',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isAdmin) ...[
                                const SizedBox(width: 6),
                                PressableScale(
                                  onPressed: () => _confirmDeleteUser(context, auth, u),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 13, color: AppColors.danger),
                                        SizedBox(width: 3),
                                        Text(
                                          'Delete',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: (idx * 30).ms);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String roleKey, String label, IconData icon) {
    final isSelected = _selectedRoleFilter == roleKey;
    return PressableScale(
      onPressed: () => setState(() => _selectedRoleFilter = roleKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _adminPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _adminPrimary : AppColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _adminPrimary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
