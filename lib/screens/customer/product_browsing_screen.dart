import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';
import 'product_detail_screen.dart';

class ProductBrowsingScreen extends StatefulWidget {
  final Widget? headerWidget;

  const ProductBrowsingScreen({super.key, this.headerWidget});

  @override
  State<ProductBrowsingScreen> createState() => _ProductBrowsingScreenState();
}

class _ProductBrowsingScreenState extends State<ProductBrowsingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final filteredProducts = productProvider.filteredProducts;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        slivers: [
          // Optional Header (Greeting, Weather, Quick Actions, Recommended)
          if (widget.headerWidget != null)
            SliverToBoxAdapter(child: widget.headerWidget!),

          // Sticky or Padded Search & Filters Container
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pill-Shaped Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search crops, farmers, mandis...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (val) => productProvider.setSearchQuery(val),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textLight),
                            onPressed: () {
                              _searchController.clear();
                              productProvider.setSearchQuery('');
                            },
                          ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.cardBorder,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                          tooltip: 'Filter by Market',
                          onSelected: (loc) => productProvider.setLocationFilter(loc),
                          itemBuilder: (ctx) {
                            final locs = ['All', ...productProvider.availableLocations];
                            return locs.map((loc) {
                              return PopupMenuItem(
                                value: loc,
                                child: Text(
                                  loc == 'All' ? 'All Markets' : loc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: productProvider.selectedLocationFilter == loc
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: productProvider.selectedLocationFilter == loc
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Category Choice Chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip(context, 'All', productProvider),
                        ...productProvider.categories.map((cat) => _buildCategoryChip(context, cat, productProvider)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Location & Distance Filter Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // GPS City Selector Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: productProvider.userCity,
                                  isDense: true,
                                  icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                  items: ['Faisalabad', 'Lahore', 'Multan', 'Rawalpindi']
                                      .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                                      .toList(),
                                  onChanged: (c) {
                                    if (c != null) productProvider.setUserCity(c);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nearest First Chip
                        _buildFilterPill(
                          label: 'Nearest First',
                          icon: Icons.near_me_rounded,
                          isSelected: productProvider.sortByNearest,
                          onTap: () => productProvider.setSortByNearest(!productProvider.sortByNearest),
                        ),
                        const SizedBox(width: 8),

                        // Distance Radius Filters
                        ...[
                          {'label': 'Any Distance', 'val': null},
                          {'label': '< 5 km (Local)', 'val': 5.0},
                          {'label': '< 15 km', 'val': 15.0},
                          {'label': '< 30 km', 'val': 30.0},
                        ].map((df) {
                          final double? val = df['val'] as double?;
                          final isSelected = productProvider.maxDistanceKm == val;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterPill(
                              label: df['label'] as String,
                              isSelected: isSelected,
                              onTap: () => productProvider.setMaxDistanceKm(val),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header Label for Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(
                      productProvider.selectedCategory == 'All'
                          ? 'Fresh Harvest (${filteredProducts.length})'
                          : '${productProvider.selectedCategory} (${filteredProducts.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (productProvider.selectedLocationFilter != 'All') ...[
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  productProvider.selectedLocationFilter,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => productProvider.setLocationFilter('All'),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.all(1),
                                  child: Icon(Icons.close_rounded, size: 13, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Product Grid or Empty State
          if (filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.primaryLight),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No matching harvest items found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try expanding distance radius or switching category filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          productProvider.setCategory('All');
                          productProvider.setLocationFilter('All');
                          productProvider.setMaxDistanceKm(null);
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                        child: const Text('Reset All Filters'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  int crossAxisCount = 2;
                  double childAspectRatio = 0.68;
                  if (width > 1200) {
                    crossAxisCount = 5;
                    childAspectRatio = 0.76;
                  } else if (width > 900) {
                    crossAxisCount = 4;
                    childAspectRatio = 0.74;
                  } else if (width > 600) {
                    crossAxisCount = 3;
                    childAspectRatio = 0.72;
                  }

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return RepaintBoundary(
                          child: _buildModernProductCard(context, product, productProvider, cartProvider),
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category, ProductProvider pp) {
    final isSelected = pp.selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PressableScale(
        onPressed: () => pp.setCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernProductCard(
    BuildContext context,
    ProductModel product,
    ProductProvider pp,
    CartProvider cp,
  ) {
    final isWishlisted = pp.isInWishlist(product.productId);
    final distanceKm = pp.getProductDistanceKm(product);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.04),
            blurRadius: 12,
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
            // Hero Image Container with Badges
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'prod_hero_${product.productId}',
                    child: HarvestImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.eco_rounded,
                    ),
                  ),
                  // Wishlist heart button with bounce
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PressableScale(
                      onPressed: () => pp.toggleWishlist(product.productId),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: isWishlisted ? Colors.red : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  // Badges: Organic / Local / Out of Stock
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!product.inStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (product.isOrganic)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '🌿 Organic',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (distanceKm <= 5.0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F3DC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nearby',
                              style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Details Body
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.farmerName ?? 'Bashir Organic Farms',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 11, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(
                              '${distanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price & Add to Cart Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Rs. ${product.pricePerUnit.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const Text(
                                'per unit',
                                style: TextStyle(fontSize: 9, color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (product.inStock)
                          PressableScale(
                            onPressed: () {
                              cp.addToCart(product);
                              showHarvestSnackBar(
                                context,
                                message: 'Added ${product.itemName} to cart',
                                icon: Icons.shopping_bag_rounded,
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          PressableScale(
                            onPressed: () {
                              final hasAlert = pp.hasRestockAlert(product.productId);
                              pp.toggleRestockAlert(product.productId, productName: product.itemName);
                              showHarvestSnackBar(
                                context,
                                message: hasAlert
                                    ? 'Restock alert removed'
                                    : 'Alert set for ${product.itemName}!',
                                icon: Icons.notifications_active_rounded,
                                backgroundColor: hasAlert ? AppColors.textSecondary : AppColors.accent,
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: pp.hasRestockAlert(product.productId)
                                    ? const Color(0xFFFFF3ED)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                pp.hasRestockAlert(product.productId)
                                    ? Icons.notifications_active_rounded
                                    : Icons.notification_add_outlined,
                                size: 16,
                                color: pp.hasRestockAlert(product.productId)
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
