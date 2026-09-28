import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/custom_toast.dart';
import 'order_history_screen.dart';

class CheckoutPickupScreen extends StatefulWidget {
  const CheckoutPickupScreen({super.key});

  @override
  State<CheckoutPickupScreen> createState() => _CheckoutPickupScreenState();
}

class _CheckoutPickupScreenState extends State<CheckoutPickupScreen> {
  String _selectedSlot = '10:00 AM - 12:00 PM';
  final List<String> _availableSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  late TextEditingController _addressController;
  final _addressFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _confirmCheckout() {
    if (!_addressFormKey.currentState!.validate()) {
      showHarvestSnackBar(
        context,
        message: 'Please confirm your delivery address before placing order.',
        icon: Icons.error_outline_rounded,
        backgroundColor: AppColors.danger,
      );
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final user = auth.currentUser;
    final customerId = user?.uid ?? 'user_cust_1';
    final customerName = user?.name ?? 'Tariq Mehmood';

    // Only order the items the customer selected in the cart
    final itemsToOrder = cart.selectedItems;

    final createdOrder = orderProvider.placeOrder(
      customerId: customerId,
      customerName: customerName,
      cartItems: itemsToOrder,
      pickupSlotTime: _selectedSlot,
      deliveryAddress: _addressController.text.trim(),
    );

    // Remove only the ordered items from cart, keep unselected ones
    for (final item in itemsToOrder) {
      cart.removeItem(item.product.productId);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Order ID: #${createdOrder.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pickup Slot', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(_selectedSlot, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text('Rs. ${createdOrder.itemsSubtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Platform Charges', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text('Rs. ${createdOrder.platformFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const Divider(color: AppColors.cardBorder, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(
                        'Rs. ${createdOrder.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Present your Order ID at your designated Farmers Market counter for direct pickup.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  );
                },
                child: const Text('View Order Tracking', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final platformFee = orderProv.platformFee;
    final selectedItems = cart.selectedItems;
    final selectedTotal = cart.selectedTotalAmount;
    final grandTotal = selectedTotal + platformFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Checkout & Pickup Schedule'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Delivery & Contact Address',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Provide your contact and delivery location details for pickup coordination:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _addressFormKey,
                        child: TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'e.g. House 14, Street 2, Gulberg III, Lahore',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textLight),
                            prefixIcon: const Icon(Icons.home_work_outlined, color: AppColors.primary),
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                          validator: (v) => Validators.validateRequired(v, 'Delivery Address'),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms),
                const SizedBox(height: 20),

                // Pickup Time Slot Selection
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select Farmers Market Pickup Window',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose an optimal time window to pick up freshly harvested crates:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      ..._availableSlots.map((slot) {
                        final isSelected = _selectedSlot == slot;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PressableScale(
                            onPressed: () => setState(() => _selectedSlot = slot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primarySurface : AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    color: isSelected ? AppColors.primary : AppColors.textLight,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Selected',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms),
                const SizedBox(height: 20),

                // Order Items Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...selectedItems.map(
                        (item) {
                          final cleanName = item.product.itemName
                              .replaceAll('(1 Litre)', '')
                              .replaceAll('(1L)', '')
                              .replaceAll('(1 kg)', '')
                              .trim();
                          final unit = item.product.unit;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity} $unit $cleanName',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(color: AppColors.cardBorder, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items Subtotal:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Rs. ${selectedTotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Platform Charges:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Rs. ${platformFee.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.cardBorder, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Rs. ${grandTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),

                // Confirm Button
                PressableScale(
                  onPressed: selectedItems.isNotEmpty ? _confirmCheckout : null,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selectedItems.isNotEmpty ? AppColors.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        if (selectedItems.isNotEmpty)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: selectedItems.isNotEmpty ? Colors.white : Colors.grey.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm & Place Order',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: selectedItems.isNotEmpty ? Colors.white : Colors.grey.shade600,
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
      ),
    );
  }
}
