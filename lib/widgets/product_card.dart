import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';
import '../screens/customer/product_detail_screen.dart';
import '../screens/bidding/bidding_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.energy_savings_leaf_outlined;
      case 'vegetables':
        return Icons.spa_outlined;
      case 'grains':
        return Icons.grass_outlined;
      default:
        return Icons.agriculture_outlined;
    }
  }

  /// Renders real photo (local file or network URL) or a gradient icon fallback.
  Widget _buildProductImage(ProductModel product) {
    final url = product.imageUrl;

    if (url.isNotEmpty) {
      if (url.startsWith('file://')) {
        final path = url.replaceFirst('file://', '');
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              _iconFallback(product.category),
        );
      } else if (url.startsWith('data:image')) {
        try {
          final commaIdx = url.indexOf(',');
          final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
          return Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                _iconFallback(product.category),
          );
        } catch (_) {
          return _iconFallback(product.category);
        }
      } else {
        return Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _iconFallback(product.category);
          },
          errorBuilder: (context, error, stackTrace) =>
              _iconFallback(product.category),
        );
      }
    }

    return _iconFallback(product.category);
  }

  Widget _iconFallback(String category) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getCategoryIcon(category),
          size: 36,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image / Crop Photo Canvas
            Container(
              height: 105,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F5EE), Color(0xFFD8F3DC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Real image or icon fallback ──────────────────
                  Hero(
                    tag: 'prod_hero_${product.productId}',
                    child: ClipRRect(
                      child: _buildProductImage(product),
                    ),
                  ),
                  if (product.isOrganic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: StatusBadge.organic(),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 15, color: Color(0xFFF4A261)),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${product.district} • ${product.farmerName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Formatters.formatCurrency(product.pricePerKg),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'per kg',
                            style: TextStyle(fontSize: 9, color: AppColors.textLight, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${product.stockKg} kg',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Actions: Add to Cart & Bargain
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: const Size(0, 34),
                            side: const BorderSide(color: AppColors.accent, width: 1.2),
                            foregroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showBargainDialog(context, product);
                          },
                          child: const Text(
                            'Bargain',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          tooltip: locale.tr('add_to_cart'),
                          onPressed: () {
                            cartProvider.addToCart(product, quantity: 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primary,
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
          ],
        ),
      ),
    );
  }
}
