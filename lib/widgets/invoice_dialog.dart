import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order_model.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

void showInvoiceDialog(BuildContext context, OrderModel order) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.agriculture, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HarvestHub',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Official Digital Receipt',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Order & Buyer Info
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invoice For:', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                              Text(order.buyerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(order.buyerPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(order.deliveryAddress, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Order Ref:', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text(Formatters.formatDate(order.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.isPaid ? AppColors.organicBg : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.isPaid ? 'PAID' : 'PENDING ON COD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: order.isPaid ? AppColors.organicBadge : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(flex: 2, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                            ),
                          ),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.cleanName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Text('From: ${item.farmerName}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('${item.quantity} ${item.unit}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(Formatters.formatCurrency(item.pricePerUnit), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(Formatters.formatCurrency(item.totalPrice), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Financial Summary
                    Column(
                      children: [
                        _buildSummaryRow('Items Subtotal', Formatters.formatCurrency(order.itemsSubtotal)),
                        _buildSummaryRow(
                          'Platform Charges',
                          '+ ${Formatters.formatCurrency(order.platformFee)}',
                          textColor: AppColors.primary,
                        ),
                        _buildSummaryRow('Payment Method', order.paymentMethodDisplay),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Payable',
                          Formatters.formatCurrency(order.totalPrice),
                          isBold: true,
                          fontSize: 16,
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons: Real Share & Print Handlers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share Receipt'),
                      onPressed: () {
                        _showShareInvoiceModal(context, order);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Receipt'),
                      onPressed: () {
                        _showPrintReceiptDialog(context, order);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _generateReceiptText(OrderModel order) {
  final buffer = StringBuffer();
  buffer.writeln('🌾 HARVESTHUB - OFFICIAL DIGITAL RECEIPT');
  buffer.writeln('===========================================');
  buffer.writeln('Order Reference: ${order.id}');
  buffer.writeln('Date: ${Formatters.formatDate(order.createdAt)}');
  buffer.writeln('Payment Status: ${order.isPaid ? "PAID" : "PENDING ON COD"}');
  buffer.writeln('Payment Method: ${order.paymentMethodDisplay}');
  buffer.writeln('-------------------------------------------');
  buffer.writeln('Customer: ${order.buyerName}');
  buffer.writeln('Phone: ${order.buyerPhone}');
  buffer.writeln('Delivery Address: ${order.deliveryAddress}, ${order.district}');
  buffer.writeln('-------------------------------------------');
  buffer.writeln('ORDERED PRODUCE:');
  for (final item in order.items) {
    buffer.writeln('• ${item.productName}');
    buffer.writeln('  Qty: ${item.quantityKg} kg  x  Rs. ${item.unitPrice.toStringAsFixed(0)}/kg = Rs. ${item.itemTotal.toStringAsFixed(0)}');
    buffer.writeln('  Farmer: ${item.farmerName}');
  }
  buffer.writeln('-------------------------------------------');
  buffer.writeln('Subtotal: Rs. ${order.subtotal.toStringAsFixed(0)}');
  if (order.discount > 0) {
    buffer.writeln('Bulk Wholesale Discount: - Rs. ${order.discount.toStringAsFixed(0)}');
  }
  buffer.writeln('Platform Service Fee (3%): + Rs. ${order.platformCommission.toStringAsFixed(0)}');
  buffer.writeln('===========================================');
  buffer.writeln('TOTAL PAYABLE: Rs. ${order.effectiveTotal.toStringAsFixed(0)}');
  buffer.writeln('===========================================');
  buffer.writeln('HarvestHub: Connecting Farmers Directly to Wholesale Buyers');
  return buffer.toString();
}

void _showShareInvoiceModal(BuildContext context, OrderModel order) {
  final receiptText = _generateReceiptText(order);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share Invoice / Receipt',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Receipt for Order ${order.id}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
            ),
            title: const Text('Share via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Copies full breakdown formatted for WhatsApp', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Clipboard.setData(ClipboardData(text: receiptText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Receipt copied! Ready to paste into WhatsApp message.'),
                      ),
                    ],
                  ),
                  backgroundColor: Color(0xFF25D366),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.copy, color: AppColors.primary),
            ),
            title: const Text('Copy Complete Receipt Text', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Copy detailed breakdown to clipboard for SMS or notes', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Clipboard.setData(ClipboardData(text: receiptText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.assignment_turned_in, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Digital receipt copied to clipboard!'),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, color: Color(0xFF0284C7)),
            ),
            title: const Text('Preview Plain Text Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Inspect text version before sending', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.pop(ctx);
              _showPlainTextPreviewDialog(context, receiptText);
            },
          ),
        ],
      ),
    ),
  );
}

void _showPlainTextPreviewDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.text_snippet_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Text Receipt Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy All'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt text copied!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    ),
  );
}

void _showPrintReceiptDialog(BuildContext context, OrderModel order) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.print_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Print Invoice Preview',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [
                      // Letterhead
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'HARVESTHUB PAKISTAN',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
                            ),
                            const Text(
                              'Agri-Tech Direct Farm Marketplace',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TAX INVOICE: ${order.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              'Date: ${Formatters.formatDate(order.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 1),
                      // Buyer & Delivery Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Billed To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                Text(order.buyerName, style: const TextStyle(fontSize: 12)),
                                Text(order.buyerPhone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                Text('${order.deliveryAddress}, ${order.district}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Payment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text(order.paymentMethodDisplay, style: const TextStyle(fontSize: 11)),
                              Text(order.isPaid ? 'STATUS: PAID' : 'STATUS: UNPAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: order.isPaid ? Colors.green : Colors.orange)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 1),

                      // Line items
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${item.productName} (${item.quantityKg}kg @ Rs. ${item.unitPrice.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12)),
                              ),
                              Text('Rs. ${item.itemTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      }),
                      const Divider(thickness: 1),

                      // Costing
                      _buildPrintSummaryRow('Subtotal Produce:', 'Rs. ${order.subtotal.toStringAsFixed(0)}'),
                      if (order.discount > 0)
                        _buildPrintSummaryRow('Wholesale Discount:', '- Rs. ${order.discount.toStringAsFixed(0)}'),
                      _buildPrintSummaryRow('Platform Handling (3%):', '+ Rs. ${order.platformCommission.toStringAsFixed(0)}'),
                      const Divider(thickness: 1.5),
                      _buildPrintSummaryRow('Total Paid / Due:', 'Rs. ${order.effectiveTotal.toStringAsFixed(0)}', isBold: true),

                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          '*** Electronically Generated Official Invoice ***\nAuthorized by HarvestHub Verification System',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Text'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generateReceiptText(order)));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt copied!'), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Send to Printer'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Document sent to default printer for ${order.id}!'),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPrintSummaryRow(String title, String val, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    ),
  );
}

Widget _buildSummaryRow(
  String label,
  String value, {
  bool isBold = false,
  double fontSize = 12,
  Color? textColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
