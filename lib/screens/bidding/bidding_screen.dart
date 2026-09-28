import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bid_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bidding_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_badge.dart';

void showBargainDialog(BuildContext context, ProductModel product) {
  final qtyController = TextEditingController(text: '50');
  final offerPriceController = TextEditingController(
    text: (product.pricePerKg * 0.85).toStringAsFixed(0),
  );
  final messageController = TextEditingController(
    text: 'Looking for a bulk harvest lot. Can we close at this rate?',
  );

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) {
        final qty = int.tryParse(qtyController.text) ?? 50;
        final offerPrice = double.tryParse(offerPriceController.text) ?? 0.0;
        final originalTotal = product.pricePerKg * qty;
        final offerTotal = offerPrice * qty;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.handshake, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bargain Price: ${product.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Listed Price: ${Formatters.formatCurrency(product.pricePerKg)} / kg',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // Lot Quantity
                const Text('Desired Quantity (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 50, 100, 200',
                    prefixIcon: Icon(Icons.scale, color: AppColors.primary),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),

                // Offered Price
                const Text('Your Offered Price (per kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: offerPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 165',
                    prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),

                // Note
                const Text('Message for Farmer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: messageController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Add terms, delivery preference or details...',
                  ),
                ),
                const SizedBox(height: 14),

                // Financial Comparison
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Original Value:'),
                          Text(Formatters.formatCurrency(originalTotal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your Proposed Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            Formatters.formatCurrency(offerTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final bidding = Provider.of<BiddingProvider>(context, listen: false);

                final buyer = auth.currentUser ??
                    UserModel(
                      uid: 'buyer_guest',
                      name: 'Direct Buyer',
                      email: 'buyer@harvesthub.pk',
                      phone: '+92 300 1234567',
                      role: 'Customer',
                      createdAt: DateTime.now(),
                    );

                bidding.createBid(
                  product: product,
                  buyer: buyer,
                  requestedQtyKg: qty,
                  offeredPricePerKg: offerPrice,
                  message: messageController.text.trim(),
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Offer of ${Formatters.formatCurrency(offerPrice)}/kg submitted to ${product.farmerName}!'),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Submit Offer'),
            ),
          ],
        );
      },
    ),
  );
}

class BiddingScreen extends StatelessWidget {
  const BiddingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bidding = Provider.of<BiddingProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);

    final user = auth.currentUser;
    final bids = bidding.bids;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.tr('bidding')),
      ),
      body: bids.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.handshake_outlined, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  const Text('No active bids yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Propose a wholesale price from any product details card.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bids.length,
              itemBuilder: (context, index) {
                final bid = bids[index];
                final isFarmer = user?.id == bid.farmerId || user?.role == 'Farmer';

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bid.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            StatusBadge.forBid(bid.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Buyer: ${bid.buyerName} • Farmer: ${bid.farmerName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const Divider(height: 20),

                        // Prices Comparison
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Original Rate', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                Text(
                                  Formatters.formatCurrency(bid.originalPricePerKg),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Offered Lot', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                Text(
                                  '${bid.requestedQtyKg} kg',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Offered Rate', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                Text(
                                  Formatters.formatCurrency(bid.offeredPricePerKg),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Counter offer alert if present
                        if (bid.counterPricePerKg != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sync_alt, size: 16, color: Color(0xFF0369A1)),
                                const SizedBox(width: 6),
                                Text(
                                  'Farmer Counter-Offered: ${Formatters.formatCurrency(bid.counterPricePerKg!)} / kg',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0369A1), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (bid.message.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            '"${bid.message}"',
                            style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],

                        // Interactive Negotiation Actions
                        if (bid.status == BidStatus.pending || bid.status == BidStatus.counterOffered) ...[
                          const Divider(height: 24),
                          _buildBiddingActions(context, bid, bidding, isFarmer),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
    );
  }

  Widget _buildBiddingActions(
    BuildContext context,
    BidModel bid,
    BiddingProvider bidding,
    bool isFarmer,
  ) {
    if (isFarmer && bid.status == BidStatus.pending) {
      return Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => bidding.declineBid(bid.id),
              child: const Text('Decline'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                _showCounterDialog(context, bid, bidding);
              },
              child: const Text('Counter Offer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => bidding.acceptBid(bid.id),
              child: const Text('Accept Offer'),
            ),
          ],
        ),
      );
    } else if (!isFarmer && bid.status == BidStatus.counterOffered) {
      return Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () => bidding.declineBid(bid.id),
              child: const Text('Decline Counter'),
            ),
            ElevatedButton(
              onPressed: () => bidding.acceptBid(bid.id),
              child: const Text('Accept Counter Offer'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showCounterDialog(BuildContext context, BidModel bid, BiddingProvider bidding) {
    final counterController = TextEditingController(
      text: ((bid.originalPricePerKg + bid.offeredPricePerKg) / 2).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Make Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buyer offered: ${Formatters.formatCurrency(bid.offeredPricePerKg)} / kg for ${bid.requestedQtyKg} kg'),
            const SizedBox(height: 12),
            const Text('Your Proposed Counter Price (per kg):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: counterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sync_alt, color: AppColors.accent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(counterController.text.trim());
              if (val != null && val > 0) {
                bidding.makeCounterOffer(bid.id, val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Counter offer of ${Formatters.formatCurrency(val)}/kg sent to buyer!'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }
}
