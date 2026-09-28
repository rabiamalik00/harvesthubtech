import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;
  bool _cartAddedAnim = false;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final isWishlisted = productProvider.isInWishlist(widget.product.productId);
    final farmerId = widget.product.farmerId;
    final isFollowing = productProvider.isFollowingFarmer(farmerId);
    final distanceKm = productProvider.getProductDistanceKm(widget.product);
    final hasAlert = productProvider.hasRestockAlert(widget.product.productId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image SliverAppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const AppBackButton(
                  color: AppColors.primary,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PressableScale(
                  onPressed: () {
                    productProvider.toggleWishlist(widget.product.productId);
                    showHarvestSnackBar(
                      context,
                      message: isWishlisted ? 'Removed from Wishlist' : 'Added to Wishlist ❤️',
                      icon: isWishlisted ? Icons.heart_broken_rounded : Icons.favorite_rounded,
                      backgroundColor: isWishlisted ? AppColors.textSecondary : const Color(0xFFE63946),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isWishlisted ? const Color(0xFFE63946) : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'prod_hero_${widget.product.productId}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HarvestImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.eco_rounded,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Product Details Content Body
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Distance Tags
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (widget.product.isOrganic) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F3DC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '🌿 100% Organic',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.product.inStock
                                ? const Color(0xFFD8F3DC)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 14,
                                color: widget.product.inStock ? AppColors.primary : AppColors.danger,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.inStock ? 'In Stock (${widget.product.stockQty})' : 'Out of Stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.product.inStock ? AppColors.primaryDark : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title & Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.itemName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${widget.product.pricePerUnit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              'per unit / kg',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Farmer Info Card (AgriCare style)
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.farmerName ?? 'Bashir Green Organic Farms',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.product.marketName ?? 'Faisalabad Model Mandi Market',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.near_me_rounded, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${distanceKm.toStringAsFixed(1)} km away',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PressableScale(
                            onPressed: () => productProvider.toggleFollowFarmer(farmerId),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isFollowing ? AppColors.primarySurface : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFollowing ? AppColors.primary : AppColors.cardBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
                                    size: 14,
                                    color: isFollowing ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFollowing ? 'Following' : 'Follow',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isFollowing ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description & Crop Insights Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Crop Information & Quality',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              PressableScale(
                                onPressed: () {
                                  setState(() => _isDescriptionExpanded = !_isDescriptionExpanded);
                                },
                                child: Text(
                                  _isDescriptionExpanded ? 'Less ↑' : 'More ↓',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description ??
                                'Freshly harvested straight from registered local farmlands. Inspected for moisture, grade-A purity, and organic soil adherence without synthetic fertilizers.',
                            maxLines: _isDescriptionExpanded ? 10 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quantity Selection (when in stock)
                    if (widget.product.inStock) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Quantity:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.cardBorder, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                PressableScale(
                                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                      color: _quantity > 1 ? AppColors.textPrimary : AppColors.textLight,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                PressableScale(
                                  onPressed: _quantity < widget.product.stockQty
                                      ? () => setState(() => _quantity++)
                                      : null,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: _quantity < widget.product.stockQty ? AppColors.primary : AppColors.textLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Sticky Floating Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: widget.product.inStock
            ? Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Price', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        'Rs. ${(widget.product.pricePerUnit * _quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: PressableScale(
                      onPressed: () {
                        setState(() => _cartAddedAnim = true);
                        final err = cartProvider.addToCart(widget.product, quantity: _quantity);
                        if (err != null) {
                          showHarvestSnackBar(
                            context,
                            message: err,
                            icon: Icons.error_outline_rounded,
                            backgroundColor: AppColors.danger,
                          );
                        } else {
                          showHarvestSnackBar(
                            context,
                            message: 'Added ${_quantity}x ${widget.product.itemName} to cart!',
                            icon: Icons.check_circle_rounded,
                          );
                        }
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (mounted) setState(() => _cartAddedAnim = false);
                        });
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _cartAddedAnim ? AppColors.primaryLight : AppColors.primary,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
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
                              _cartAddedAnim ? Icons.check_rounded : Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _cartAddedAnim ? 'Added to Cart!' : 'Add to Cart',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : PressableScale(
                onPressed: () {
                  productProvider.toggleRestockAlert(
                    widget.product.productId,
                    productName: widget.product.itemName,
                  );
                  showHarvestSnackBar(
                    context,
                    message: hasAlert
                        ? 'Restock alert removed for ${widget.product.itemName}'
                        : 'Alert active! We will notify you when ${widget.product.itemName} restocks.',
                    icon: hasAlert ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
                    backgroundColor: hasAlert ? AppColors.textSecondary : AppColors.accent,
                  );
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: hasAlert ? const Color(0xFFFFF3ED) : AppColors.primary,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: hasAlert ? AppColors.accent : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasAlert ? Icons.notifications_active_rounded : Icons.notification_add_outlined,
                        color: hasAlert ? AppColors.accent : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasAlert ? 'Restock Alert Active (Subscribed)' : 'Notify Me When Restocked',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: hasAlert ? AppColors.accent : Colors.white,
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
