import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/bid_model.dart';
import '../models/dispute_model.dart';
import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.organic() {
    return const StatusBadge(
      label: 'ORGANIC',
      backgroundColor: AppColors.organicBg,
      textColor: AppColors.organicBadge,
      icon: Icons.eco,
    );
  }

  factory StatusBadge.forOrder(OrderStatus status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case OrderStatus.placed:
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0369A1);
        icon = Icons.receipt_long;
        break;
      case OrderStatus.processing:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        icon = Icons.inventory_2;
        break;
      case OrderStatus.readyForPickup:
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF7E22CE);
        icon = Icons.local_shipping;
        break;
      case OrderStatus.outForDelivery:
        bg = const Color(0xFFFFEDD5);
        text = const Color(0xFFC2410C);
        icon = Icons.directions_bike;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        icon = Icons.cancel;
        break;
    }

    String label;
    switch (status) {
      case OrderStatus.placed:
        label = 'Placed';
        break;
      case OrderStatus.processing:
        label = 'Processing';
        break;
      case OrderStatus.readyForPickup:
        label = 'Packed';
        break;
      case OrderStatus.outForDelivery:
        label = 'On the Way';
        break;
      case OrderStatus.delivered:
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        label = 'Cancelled';
        break;
    }

    return StatusBadge(
      label: label,
      backgroundColor: bg,
      textColor: text,
      icon: icon,
    );
  }

  factory StatusBadge.forBid(BidStatus status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case BidStatus.pending:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        label = 'Offer Pending';
        icon = Icons.hourglass_top;
        break;
      case BidStatus.counterOffered:
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0369A1);
        label = 'Counter Offered';
        icon = Icons.sync_alt;
        break;
      case BidStatus.accepted:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        label = 'Offer Accepted';
        icon = Icons.handshake;
        break;
      case BidStatus.declined:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = 'Declined';
        icon = Icons.close;
        break;
    }

    return StatusBadge(
      label: label,
      backgroundColor: bg,
      textColor: text,
      icon: icon,
    );
  }

  factory StatusBadge.forDispute(DisputeStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case DisputeStatus.open:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = 'Open Case';
        break;
      case DisputeStatus.underReview:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        label = 'Under Review';
        break;
      case DisputeStatus.resolved:
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        label = 'Resolved';
        break;
      case DisputeStatus.refunded:
        bg = const Color(0xFFE0E7FF);
        text = const Color(0xFF4338CA);
        label = 'Refunded';
        break;
    }

    return StatusBadge(
      label: label,
      backgroundColor: bg,
      textColor: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
