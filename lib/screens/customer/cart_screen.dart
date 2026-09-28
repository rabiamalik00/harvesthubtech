import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';
import 'checkout_pickup_screen.dart';

class CartScreen extends StatelessWidget {
  final bool showAppBar;
  const CartScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final selectedCount = cart.selectedIds.length;
    final hasItems = cart.itemCount > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              leading: const AppBackButton(),
              title: const Text('Shopping Cart'),
              actions: [
                if (hasItems)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Clear Cart',
                    onPressed: () => _confirmClearCart(context, cart),
                  ),
              ],
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: !hasItems
              ? const _EmptyCart()
              : Column(
                  children: [
                    // Select All Bar
                    _SelectAllBar(cart: cart),

                    // Item List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        itemCount: cart.itemList.length,
                        itemBuilder: (context, index) {
                          final item = cart.itemList[index];
                          final isSelected = cart.isSelected(item.product.productId);
                          return _CartItemTile(
                            item: item,
                            isSelected: isSelected,
                            onToggleSelect: () => cart.toggleSelection(item.product.productId),
                            onIncrement: () => cart.incrementQuantity(item.product.productId),
                            onDecrement: () => cart.decrementQuantity(item.product.productId),
                            onRemove: () => cart.removeItem(item.product.productId),
                          )
                              .animate()
                              .fadeIn(duration: 200.ms, delay: (index * 30).ms)
                              .slideY(begin: 0.05, end: 0);
                        },
                      ),
                    ),

                    // Checkout Footer
                    _CheckoutFooter(
                      cart: cart,
                      selectedCount: selectedCount,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Clear Shopping Cart?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _SelectAllBar extends StatelessWidget {
  final CartProvider cart;
  const _SelectAllBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          PressableScale(
            onPressed: cart.toggleSelectAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: cart.allSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: cart.allSelected ? AppColors.primary : AppColors.cardBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: cart.allSelected
                      ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  cart.allSelected ? 'Deselect All' : 'Select All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: cart.allSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${cart.selectedIds.length} of ${cart.itemCount} selected',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryLight : AppColors.cardBorder,
          width: isSelected ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: isSelected ? 0.06 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            PressableScale(
              onPressed: onToggleSelect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Product Image Thumbnail
            HarvestImage(
              imageUrl: item.product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(14),
              fallbackIcon: Icons.eco_rounded,
            ),
            const SizedBox(width: 14),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${item.product.pricePerUnit.toStringAsFixed(0)} / unit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Stepper Controls
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  PressableScale(
                    onPressed: onDecrement,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  PressableScale(
                    onPressed: onIncrement,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Remove button
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
              onPressed: onRemove,
              tooltip: 'Remove',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  final CartProvider cart;
  final int selectedCount;

  const _CheckoutFooter({
    required this.cart,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = cart.selectedTotalAmount;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Items ($selectedCount)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rs. ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: PressableScale(
                    onPressed: selectedCount == 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutPickupScreen()),
                            );
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: selectedCount == 0 ? Colors.grey.shade300 : AppColors.primary,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          if (selectedCount > 0)
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
                            Icons.shopping_cart_checkout_rounded,
                            color: selectedCount == 0 ? Colors.grey.shade500 : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: selectedCount == 0 ? Colors.grey.shade600 : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_shopping_cart_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Shopping Cart is Empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore fresh farm produce, organic fruits, and grains directly from Punjab farmers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
