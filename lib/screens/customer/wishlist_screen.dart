import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final bool showAppBar;
  const WishlistScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final wishlist = productProvider.wishlistProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              leading: const AppBackButton(),
              title: const Text('My Saved Items'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: wishlist.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 56,
                            color: Color(0xFFE63946),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your Wishlist is Empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Heart crops and harvest goods while browsing to save them for later or receive restock alerts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final product = wishlist[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              HarvestImage(
                                imageUrl: product.imageUrl,
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(14),
                                fallbackIcon: Icons.eco_rounded,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        if (product.isOrganic) ...[
                                          const SizedBox(width: 6),
                                          const Text('🌿 Organic', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${product.pricePerUnit.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PressableScale(
                                    onPressed: () {
                                      cartProvider.addToCart(product);
                                      showHarvestSnackBar(
                                        context,
                                        message: 'Moved ${product.itemName} to Cart!',
                                        icon: Icons.shopping_bag_rounded,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PressableScale(
                                    onPressed: () {
                                      productProvider.toggleWishlist(product.productId);
                                      showHarvestSnackBar(
                                        context,
                                        message: 'Removed from Saved Items',
                                        icon: Icons.heart_broken_rounded,
                                        backgroundColor: AppColors.textSecondary,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 200.ms, delay: (index * 30).ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                ),
        ),
      ),
    );
  }
}
