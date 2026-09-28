import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('fruit')) return Icons.apple_rounded;
    if (lower.contains('veg')) return Icons.eco_rounded;
    if (lower.contains('grain') || lower.contains('wheat') || lower.contains('rice')) {
      return Icons.grain_rounded;
    }
    if (lower.contains('dairy') || lower.contains('milk')) {
      return Icons.egg_alt_rounded;
    }
    if (lower.contains('herb') || lower.contains('spice')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('organic')) return Icons.nature_people_rounded;
    return Icons.category_rounded;
  }

  void _showAddCategoryDialog(BuildContext context, ProductProvider pp) {
    _addController.clear();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_box_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Add New Category',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categories are synced with Cloud Firestore and instantly update customer filters and farmer listing forms.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Pulses & Lentils, Organic Honey',
                  prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a category name';
                  final trimmed = val.trim();
                  if (pp.categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
                    return 'This category already exists';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          PressableScale(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newCat = _addController.text.trim();
                Navigator.pop(ctx);
                await pp.addCategory(newCat);
                if (context.mounted) {
                  showHarvestSnackBar(
                    context,
                    message: 'Category "$newCat" added and synced successfully!',
                    icon: Icons.check_circle_rounded,
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Add Category',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, ProductProvider pp, String category) {
    final count = pp.getProductCountForCategory(category);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Delete Category',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove "$category"?',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            if (count > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: $count active product(s) are currently categorized under "$category".',
                        style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'This category currently has zero products listed.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          PressableScale(
            onPressed: () async {
              Navigator.pop(ctx);
              await pp.deleteCategory(category);
              if (context.mounted) {
                showHarvestSnackBar(
                  context,
                  message: 'Category "$category" removed.',
                  icon: Icons.delete_outline_rounded,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryListingsModal(BuildContext context, ProductProvider pp, String category) {
    final products = pp.products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_getCategoryIcon(category), color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$category Listings',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${products.length} active item(s) currently listed',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                const Divider(),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No listings in "$category"',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Farmers have not yet added any products under this category.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (context, idx) {
                            final p = products[idx];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.primarySurface,
                                    child: p.imageUrl.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.eco_rounded, color: AppColors.primary),
                                          )
                                        : const Icon(Icons.eco_rounded, color: AppColors.primary),
                                  ),
                                ),
                                title: Text(
                                  p.itemName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Text(
                                      'Farmer: ${p.farmerName ?? "Farmer ID: ${p.farmerId}"}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                       spacing: 6,
                                       runSpacing: 3,
                                       crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          'Rs. ${p.pricePerUnit.toStringAsFixed(0)} / kg',
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.stockQty > 0 ? const Color(0xFFE8F5EE) : const Color(0xFFFFEBEE),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Stock: ${p.stockQty}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: p.stockQty > 0 ? AppColors.primary : AppColors.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                  tooltip: 'Delete listing',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogCtx) => AlertDialog(
                                        title: const Text('Delete Listing?'),
                                        content: Text('Are you sure you want to delete "${p.itemName}" from this category?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogCtx),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogCtx);
                                              pp.deleteProduct(p.productId);
                                              if (context.mounted) {
                                                showHarvestSnackBar(
                                                  context,
                                                  message: 'Product "${p.itemName}" deleted.',
                                                  icon: Icons.check_circle_rounded,
                                                );
                                              }
                                            },
                                            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, pp, _) {
        final categories = pp.categories;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Manage Categories',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            backgroundColor: const Color(0xFF3B0764),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF6D28D9),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Category',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showAddCategoryDialog(context, pp),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.category_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Categories Found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "Add Category" to create a new product classification',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final count = pp.getProductCountForCategory(cat);
                        final icon = _getCategoryIcon(cat);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
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
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _showCategoryListingsModal(context, pp, cat),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icon, color: AppColors.primary, size: 22),
                              ),
                              title: Text(
                                cat,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: count > 0 ? const Color(0xFFE8F5EE) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count active listing(s)',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: count > 0 ? AppColors.primary : AppColors.textLight,
                                    ),
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                tooltip: 'Delete category',
                                onPressed: () => _confirmDeleteCategory(context, pp, cat),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 250.ms, delay: (index * 30).ms).slideY(begin: 0.04, end: 0);
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}