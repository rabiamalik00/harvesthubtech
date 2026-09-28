import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app_config/theme.dart';
import '../../core/services/support_service.dart';
import '../../core/utils/validators.dart';
import '../../models/support_query_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';

const _adminPurple = Color(0xFF5B21B6);

class ContactUsScreen extends StatefulWidget {
  final String? role;

  const ContactUsScreen({super.key, this.role});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter State
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All' | 'Pending' | 'In Review' | 'Resolved'
  final TextEditingController _searchCtrl = TextEditingController();

  // User Inquiry Form State
  final _inquiryFormKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _selectedCategory = 'Pickup & Logistics';

  // Review Form State
  final _reviewFormKey = GlobalKey<FormState>();
  final _reviewCommentCtrl = TextEditingController();
  final _targetFarmerCtrl = TextEditingController(text: 'Bashir Green Organic Farms • Faisalabad Mandi');
  double _selectedRating = 5.0;

  @override
  void initState() {
    super.initState();
    SupportService.init();
    SupportService.syncRevision.addListener(_onSyncRevisionChanged);
    final isAdmin = widget.role?.toLowerCase() == 'admin';
    _tabController = TabController(length: isAdmin ? 3 : 3, vsync: this);
  }

  void _onSyncRevisionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SupportService.syncRevision.removeListener(_onSyncRevisionChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    _reviewCommentCtrl.dispose();
    _targetFarmerCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------

  void _submitUserInquiry(AuthProvider auth) {
    if (!_inquiryFormKey.currentState!.validate()) return;

    final user = auth.currentUser;
    final userName = user?.name ?? 'HarvestHub Member';
    final userEmail = user?.email ?? 'user@harvesthub.pk';
    final userRole = user?.isFarmer == true ? 'Farmer' : 'Customer';

    final newQuery = SupportQueryModel(
      id: 'QRY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: user?.uid ?? 'guest',
      userName: userName,
      userEmail: userEmail,
      userRole: userRole,
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      category: _selectedCategory,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    SupportService.addQuery(newQuery);

    _subjectCtrl.clear();
    _messageCtrl.clear();

    setState(() {});

    showHarvestSnackBar(
      context,
      message: 'Inquiry submitted! Our support team will review and reply shortly.',
      icon: Icons.mark_email_read_rounded,
      backgroundColor: AppColors.success,
    );
  }

  void _submitCustomerReview(AuthProvider auth) {
    if (!_reviewFormKey.currentState!.validate()) return;

    final user = auth.currentUser;
    final customerName = user?.name ?? 'Verified Buyer';
    final customerEmail = user?.email ?? 'buyer@harvesthub.pk';

    final newReview = CustomerReviewModel(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      customerName: customerName,
      customerEmail: customerEmail,
      targetFarmerOrMandi: _targetFarmerCtrl.text.trim(),
      rating: _selectedRating,
      comment: _reviewCommentCtrl.text.trim(),
      createdAt: DateTime.now(),
      verifiedPurchase: true,
    );

    SupportService.addReview(newReview);
    _reviewCommentCtrl.clear();

    setState(() {});

    showHarvestSnackBar(
      context,
      message: 'Thank you! Your verified review and rating has been recorded.',
      icon: Icons.star_rounded,
      backgroundColor: Colors.amber.shade900,
    );
  }

  void _showUpdateQueryDialog(SupportQueryModel query) {
    _showQueryDetailsSheet(query);
  }

  void _showQueryDetailsSheet(SupportQueryModel query) {
    String tempStatus = query.status;
    final replyCtrl = TextEditingController(text: query.adminReply ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isResolved = tempStatus == 'Resolved';
          final isInReview = tempStatus == 'In Review';
          final statusColor = isResolved
              ? AppColors.success
              : (isInReview ? Colors.blue.shade700 : Colors.orange.shade800);
          final statusBg = isResolved
              ? const Color(0xFFD8F3DC)
              : (isInReview ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7));

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
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: _adminPurple, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket #${query.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${query.category} • ${DateFormat('dd MMM yyyy, hh:mm a').format(query.createdAt)}',
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

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isResolved
                                      ? Icons.check_circle_rounded
                                      : (isInReview
                                          ? Icons.hourglass_top_rounded
                                          : Icons.pending_rounded),
                                  size: 16,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Current Status: $tempStatus',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sender Details
                          const Text(
                            'User Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
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
                                Row(
                                  children: [
                                    const Text('Name:',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                    const Spacer(),
                                    Text('${query.userName} (${query.userRole})',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (query.userEmail.isNotEmpty) ...[
                                  const Divider(height: 12),
                                  Row(
                                    children: [
                                      const Text('Email:',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary)),
                                      const Spacer(),
                                      Text(query.userEmail,
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subject & Message
                          const Text(
                            'Inquiry Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  query.subject,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  query.message,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Update Status Chips
                          const Text(
                            'Update Ticket Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: ['Pending', 'In Review', 'Resolved']
                                .map((s) {
                              final isCur = tempStatus == s;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(s,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isCur
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      )),
                                  selected: isCur,
                                  selectedColor: _adminPurple,
                                  labelStyle: TextStyle(
                                    color: isCur ? Colors.white : AppColors.textPrimary,
                                  ),
                                  onSelected: (_) {
                                    setSheetState(() => tempStatus = s);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Admin Reply TextField
                          const Text(
                            'Admin Resolution Note / Reply',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: replyCtrl,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: InputDecoration(
                              hintText:
                                  'Write reply or instructions for the user...',
                              hintStyle: const TextStyle(
                                  fontSize: 12, color: AppColors.textLight),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Save Changes Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _adminPurple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await SupportService.updateQueryStatus(
                                  query.id,
                                  tempStatus,
                                  adminReply: replyCtrl.text.trim().isNotEmpty
                                      ? replyCtrl.text.trim()
                                      : null,
                                );
                                if (mounted) {
                                  setState(() {});
                                  showHarvestSnackBar(
                                    context,
                                    message:
                                        'Inquiry ticket updated successfully.',
                                    icon: Icons.check_circle_rounded,
                                    backgroundColor: AppColors.success,
                                  );
                                }
                              },
                              child: const Text(
                                'Save & Send Reply',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Delete Ticket Option
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 16, color: AppColors.danger),
                              label: const Text(
                                'Delete This Ticket',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.danger),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Ticket?'),
                                    content: const Text(
                                        'Are you sure you want to permanently delete this ticket?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.danger),
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Delete',
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  if (!context.mounted) return;
                                  Navigator.pop(ctx);
                                  await SupportService.deleteQuery(query.id);
                                  if (mounted) {
                                    setState(() {});
                                    showHarvestSnackBar(
                                      context,
                                      message: 'Ticket deleted.',
                                      icon: Icons.delete_outline,
                                      backgroundColor: AppColors.danger,
                                    );
                                  }
                                }
                              },
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

  void _showReviewDetailsSheet(CustomerReviewModel review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.40,
        maxChildSize: 0.90,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
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
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Customer Review Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
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
                      // Reviewer & Rating Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFFFFBEB),
                                  child: Text(
                                    review.customerName.isNotEmpty
                                        ? review.customerName[0].toUpperCase()
                                        : 'C',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.customerName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        review.targetFarmerOrMandi,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          size: 16, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        review.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.amber.shade900),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(review.createdAt)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textLight),
                                ),
                                const Row(
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        size: 13, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text('Verified Purchase',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Comment
                      const Text(
                        'Customer Feedback',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          review.comment,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.45),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delete Review Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.danger),
                          label: const Text(
                            'Delete Review',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete Review?'),
                                content: const Text(
                                    'Are you sure you want to remove this customer review?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger),
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (!context.mounted) return;
                              Navigator.pop(ctx);
                              await SupportService.deleteReview(review.id);
                              if (mounted) {
                                setState(() {});
                                showHarvestSnackBar(
                                  context,
                                  message: 'Review removed successfully.',
                                  icon: Icons.delete_outline,
                                  backgroundColor: AppColors.danger,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD ENTRY POINT
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = widget.role?.toLowerCase() == 'admin';

    if (isAdmin) {
      return _buildAdminQueriesDesk(context, auth);
    } else {
      return _buildUserSupportDesk(context, auth);
    }
  }

  // ===========================================================================
  // 1. ADMIN QUERIES & CUSTOMER REVIEWS VIEW
  // ===========================================================================

  Widget _buildAdminQueriesDesk(BuildContext context, AuthProvider auth) {
    final allQueries = SupportService.queries;
    final allReviews = SupportService.reviews;

    final farmerQueries = allQueries.where((q) => q.userRole == 'Farmer').toList();
    final customerQueries = allQueries.where((q) => q.userRole == 'Customer').toList();

    double avgRating = 5.0;
    if (allReviews.isNotEmpty) {
      final total = allReviews.fold<double>(0.0, (acc, r) => acc + r.rating);
      avgRating = total / allReviews.length;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _adminPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Queries & Customer Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF4C1D95),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.amberAccent,
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.agriculture_rounded, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Farmers (${farmerQueries.length})',
                          style: const TextStyle(fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_rounded, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Customers (${customerQueries.length})',
                          style: const TextStyle(fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amberAccent),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Reviews (${allReviews.length})',
                          style: const TextStyle(fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
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
      body: Column(
        children: [
          // Top Stats Metric Row
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildAdminMiniMetric(
                    label: 'Farmer Tickets',
                    count: '${farmerQueries.length}',
                    color: AppColors.primary,
                    icon: Icons.agriculture_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildAdminMiniMetric(
                    label: 'Buyer Queries',
                    count: '${customerQueries.length}',
                    color: Colors.blue.shade700,
                    icon: Icons.contact_support_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildAdminMiniMetric(
                    label: 'Avg Rating',
                    count: '⭐ ${avgRating.toStringAsFixed(1)}',
                    color: Colors.amber.shade900,
                    icon: Icons.reviews_rounded,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Search & Status Filter Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Search queries, user name, farm, feedback...',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 9),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textLight),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'In Review', 'Resolved'].map((st) {
                      final isSel = _statusFilter == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _statusFilter = st),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? _adminPurple : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              st,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                color: isSel ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Tab Bar View with Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Farmer Queries
                _buildQueriesList(farmerQueries, isFarmer: true),
                // Tab 2: Customer Queries
                _buildQueriesList(customerQueries, isFarmer: false),
                // Tab 3: Customer Reviews
                _buildReviewsList(allReviews),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMiniMetric({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueriesList(List<SupportQueryModel> list, {required bool isFarmer}) {
    final filtered = list.where((q) {
      if (_statusFilter != 'All' && q.status != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final matchesSubject = q.subject.toLowerCase().contains(_searchQuery);
        final matchesMsg = q.message.toLowerCase().contains(_searchQuery);
        final matchesUser = q.userName.toLowerCase().contains(_searchQuery);
        final matchesCat = q.category.toLowerCase().contains(_searchQuery);
        return matchesSubject || matchesMsg || matchesUser || matchesCat;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No ${_statusFilter != 'All' ? _statusFilter : ''} ${isFarmer ? 'Farmer' : 'Customer'} queries found',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'New inquiries submitted through the portal will appear here in real-time.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final q = filtered[index];
        final isResolved = q.status == 'Resolved';
        final isInReview = q.status == 'In Review';

        final Color statusColor = isResolved
            ? AppColors.success
            : (isInReview ? Colors.blue.shade700 : Colors.orange.shade800);
        final Color statusBg = isResolved
            ? const Color(0xFFD8F3DC)
            : (isInReview ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showQueryDetailsSheet(q),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top row: Category Chip + Status Badge + ID
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isFarmer ? AppColors.primarySurface : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFarmer ? AppColors.primary : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isResolved
                                ? Icons.check_circle_rounded
                                : (isInReview ? Icons.hourglass_top_rounded : Icons.pending_rounded),
                            size: 11,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            q.status,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      q.id,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subject
                Text(
                  q.subject,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),

                // Message Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    q.message,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),

                if (q.adminReply != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.reply_rounded, size: 14, color: _adminPurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Admin Resolution Note:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _adminPurple)),
                              Text(q.adminReply!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF3B0764))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 8),

                // Sender Info & Manage Action
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isFarmer ? AppColors.primarySurface : const Color(0xFFE0F2FE),
                      child: Text(
                        q.userName.isNotEmpty ? q.userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFarmer ? AppColors.primary : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.userName,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${DateFormat('dd MMM, hh:mm a').format(q.createdAt)} • ${q.userEmail}',
                            style: const TextStyle(fontSize: 9.5, color: AppColors.textLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    PressableScale(
                      onPressed: () => _showUpdateQueryDialog(q),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 14, color: _adminPurple),
                            SizedBox(width: 4),
                            Text(
                              'Action',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _adminPurple),
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildReviewsList(List<CustomerReviewModel> list) {
    final filtered = list.where((r) {
      if (_searchQuery.isNotEmpty) {
        final matchesName = r.customerName.toLowerCase().contains(_searchQuery);
        final matchesComment = r.comment.toLowerCase().contains(_searchQuery);
        final matchesTarget = r.targetFarmerOrMandi.toLowerCase().contains(_searchQuery);
        return matchesName || matchesComment || matchesTarget;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No matching customer reviews found.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final r = filtered[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showReviewDetailsSheet(r),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top Row: Reviewer + Stars + Verified Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFFFFBEB),
                      child: Text(
                        r.customerName.isNotEmpty ? r.customerName[0].toUpperCase() : 'C',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  r.customerName,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                            ],
                          ),
                          Text(
                            r.targetFarmerOrMandi,
                            style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            r.rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Review Comment
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    r.comment,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                  ),
                ),
                const SizedBox(height: 8),

                // Bottom timestamp & verified badge (NO OVERFLOW)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Verified • ${DateFormat('dd MMM yyyy').format(r.createdAt)}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 12, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text(
                          'Mandi Delivery',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  // ===========================================================================
  // 2. USER (CUSTOMER & FARMER) SUPPORT & REVIEW DESK
  // ===========================================================================

  Widget _buildUserSupportDesk(BuildContext context, AuthProvider auth) {
    final isFarmer = widget.role?.toLowerCase() == 'farmer';
    final user = auth.currentUser;

    final themeColor = isFarmer ? AppColors.accent : AppColors.primary;
    final appBarColor = isFarmer ? const Color(0xFF854D0E) : const Color(0xFF1B4332);

    final userQueries = SupportService.queries.where((q) {
      if (user != null) {
        return q.userEmail == user.email || q.userId == user.uid;
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isFarmer ? 'Farmer Support & Mandi Help' : 'Customer Support & Reviews',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.black.withValues(alpha: 0.15),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              tabs: [
                const Tab(text: 'Submit Inquiry'),
                const Tab(text: 'Write Review'),
                Tab(text: 'My Tickets (${userQueries.length})'),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Submit Inquiry Form
              _buildInquiryTab(context, auth, themeColor, isFarmer),

              // TAB 2: Write Review Form
              _buildReviewTab(context, auth, themeColor),

              // TAB 3: My Inquiries List
              _buildMyTicketsTab(userQueries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInquiryTab(BuildContext context, AuthProvider auth, Color themeColor, bool isFarmer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Helpline Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFarmer
                    ? [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)]
                    : [const Color(0xFFD8F3DC), const Color(0xFFB7E4C7)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_in_talk_rounded, color: themeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFarmer ? 'Direct Kisan Hotline' : 'Customer Mandi Helpline',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Toll-Free: +92 300 1234567 • 7:00 AM – 9:00 PM',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Inquiry Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Form(
              key: _inquiryFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Submit Support Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Our operations team responds within 2-4 hours.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 16),

                  // Category Selector
                  const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      'Pickup & Logistics',
                      'Product Quality',
                      'Payout & Settlement',
                      'Mandi Rates',
                      'Crop Advisory',
                      'General Inquiry',
                    ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Subject
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Brief summary of your question or issue',
                      prefixIcon: Icon(Icons.subject_rounded),
                    ),
                    validator: (v) => Validators.validateRequired(v, 'Subject'),
                  ),
                  const SizedBox(height: 14),

                  // Message
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Message',
                      hintText: 'Provide details like order ID, mandi name, or crop type...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => Validators.validateRequired(v, 'Message'),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send Inquiry to HarvestHub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      onPressed: () => _submitUserInquiry(auth),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(BuildContext context, AuthProvider auth, Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Form(
          key: _reviewFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a Customer Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Rate your produce freshness and local mandi pickup experience.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 18),

              // Interactive Star Rating Bar
              Center(
                child: Column(
                  children: [
                    const Text('Your Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = index + 1.0;
                        return IconButton(
                          iconSize: 32,
                          icon: Icon(
                            starVal <= _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber.shade700,
                          ),
                          onPressed: () => setState(() => _selectedRating = starVal),
                        );
                      }),
                    ),
                    Text(
                      '${_selectedRating.toInt()} / 5 Stars',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Target Farmer / Mandi
              TextFormField(
                controller: _targetFarmerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Farmer / Mandi Hub',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: (v) => Validators.validateRequired(v, 'Farmer / Mandi'),
              ),
              const SizedBox(height: 14),

              // Review Comment
              TextFormField(
                controller: _reviewCommentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your Experience & Feedback',
                  hintText: 'Describe harvest quality, packing, price fairness...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.validateRequired(v, 'Review comment'),
              ),
              const SizedBox(height: 20),

              // Submit Review Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.rate_review_rounded, size: 18),
                  label: const Text('Post Verified Customer Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  onPressed: () => _submitCustomerReview(auth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTicketsTab(List<SupportQueryModel> myQueries) {
    if (myQueries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('No tickets submitted yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Switch to "Submit Inquiry" tab to ask a question or report an issue.', style: TextStyle(fontSize: 12, color: AppColors.textLight), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myQueries.length,
      itemBuilder: (context, idx) {
        final q = myQueries[idx];
        final isResolved = q.status == 'Resolved';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(q.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isResolved ? const Color(0xFFD8F3DC) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isResolved ? AppColors.success : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(q.subject, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
              const SizedBox(height: 4),
              Text(q.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (q.adminReply != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'HarvestHub Team: ${q.adminReply!}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF14532D), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
