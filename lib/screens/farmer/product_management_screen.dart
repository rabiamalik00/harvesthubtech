import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/harvest_image.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  void _showAddEditProductDialog([ProductModel? existingProduct]) {
    final nameController = TextEditingController(text: existingProduct?.itemName ?? '');
    final priceController = TextEditingController(text: existingProduct?.pricePerUnit.toStringAsFixed(0) ?? '');
    final stockController = TextEditingController(text: existingProduct?.stockQty.toString() ?? '');
    final isExistingBase64 = existingProduct?.imageUrl.startsWith('data:image') ?? false;
    Uint8List? selectedImageBytes;
    String? selectedBase64;
    if (isExistingBase64) {
      selectedBase64 = existingProduct!.imageUrl;
      try {
        final commaIdx = selectedBase64.indexOf(',');
        final b64 = commaIdx != -1 ? selectedBase64.substring(commaIdx + 1) : selectedBase64;
        selectedImageBytes = base64Decode(b64);
      } catch (_) {}
    }
    final imageController = TextEditingController(
        text: isExistingBase64 ? '' : (existingProduct?.imageUrl ?? ''));
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final availableCategories = productProvider.categories;
    String selectedCategory = existingProduct?.category ?? (availableCategories.isNotEmpty ? availableCategories.first : 'Vegetables');
    if (!availableCategories.contains(selectedCategory) && availableCategories.isNotEmpty) {
      selectedCategory = availableCategories.first;
    }

    final formKey = GlobalKey<FormState>();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final mandiMarkets = [
      'Faisalabad Model Mandi Market',
      'Lahore Model Agriculture Bazaar',
      'Multan Grain & Vegetable Mandi',
      'Rawalpindi Sabzi Mandi',
    ];
    String selectedMarket = existingProduct?.marketName ?? (auth.currentUser?.marketName ?? 'Faisalabad Model Mandi Market');
    if (!mandiMarkets.contains(selectedMarket)) {
      mandiMarkets.add(selectedMarket);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    existingProduct == null ? Icons.add_circle_outline_rounded : Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  existingProduct == null ? 'Add Farm Harvest' : 'Edit Product',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Crop / Item Name',
                        hintText: 'e.g. Fresh Red Tomatoes',
                        prefixIcon: Icon(Icons.eco_rounded, color: AppColors.primary),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter item name' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: availableCategories.contains(selectedCategory)
                                ? selectedCategory
                                : (availableCategories.isNotEmpty ? availableCategories.first : null),
                            isExpanded: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
                            ),
                            items: availableCategories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedCategory = val);
                            },
                            validator: (v) => (v == null || v.isEmpty) ? 'Select a category' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // "+ Add Category" button
                        Tooltip(
                          message: 'Add new category',
                          child: GestureDetector(
                            onTap: () async {
                              final newCat = await _showAddCategoryDialog(context);
                              if (newCat != null && newCat.isNotEmpty) {
                                if (!context.mounted) return;
                                final pp = Provider.of<ProductProvider>(context, listen: false);
                                await pp.addCategory(newCat);
                                setDialogState(() => selectedCategory = newCat);
                              }
                            },
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMarket,
                      decoration: const InputDecoration(
                        labelText: 'Mandi / Market Location',
                        prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.primary),
                      ),
                      isExpanded: true,
                      items: mandiMarkets
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMarket = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price per Unit (Rs.)',
                        hintText: '140',
                        prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                      ),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Available Stock Quantity',
                        hintText: '50',
                        prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      ),
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid stock' : null,
                    ),
                    const SizedBox(height: 12),
                    // Product Image — icon-only picker, no pre-loaded placeholder
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.photo_camera_back_outlined, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'Product Image',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Dedicated thumbnail preview card if an image is attached/entered
                          if (selectedImageBytes != null || imageController.text.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: selectedImageBytes != null
                                        ? Image.memory(
                                            selectedImageBytes!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          )
                                        : HarvestImage(
                                            imageUrl: imageController.text,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, size: 13, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              selectedImageBytes != null ? 'Photo Attached' : 'Image URL Attached',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          selectedImageBytes != null ? 'Ready to upload' : imageController.text,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setDialogState(() {
                                      selectedImageBytes = null;
                                      selectedBase64 = null;
                                      imageController.clear();
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Row(
                            children: [
                              // Camera icon button
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final XFile? photo = await picker.pickImage(
                                      source: ImageSource.camera,
                                      maxWidth: 500,
                                      maxHeight: 500,
                                      imageQuality: 70,
                                    );
                                    if (photo != null) {
                                      final bytes = await photo.readAsBytes();
                                      setDialogState(() {
                                        selectedImageBytes = bytes;
                                        selectedBase64 =
                                            'data:image/jpeg;base64,${base64Encode(bytes)}';
                                        imageController.clear();
                                      });
                                    }
                                  } catch (e) {
                                    debugPrint('Camera error: $e');
                                  }
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      color: AppColors.primary, size: 22),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Gallery icon button
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 500,
                                      maxHeight: 500,
                                      imageQuality: 70,
                                    );
                                    if (image != null) {
                                      final bytes = await image.readAsBytes();
                                      setDialogState(() {
                                        selectedImageBytes = bytes;
                                        selectedBase64 =
                                            'data:image/jpeg;base64,${base64Encode(bytes)}';
                                        imageController.clear();
                                      });
                                    }
                                  } catch (e) {
                                    debugPrint('Gallery error: $e');
                                  }
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0E6),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.photo_library_rounded,
                                      color: AppColors.accent, size: 22),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // URL input
                              Expanded(
                                child: TextFormField(
                                  controller: imageController,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    hintText: 'Or paste image URL...',
                                    prefixIcon: const Icon(Icons.link_rounded,
                                        size: 16, color: AppColors.textSecondary),
                                    suffixIcon: imageController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 14),
                                            onPressed: () => setDialogState(
                                                () => imageController.clear()),
                                          )
                                        : null,
                                  ),
                                  onChanged: (val) {
                                    if (val.isNotEmpty && selectedBase64 != null) {
                                      setDialogState(() {
                                        selectedImageBytes = null;
                                        selectedBase64 = null;
                                      });
                                    } else {
                                      setDialogState(() {});
                                    }
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  final productProvider = Provider.of<ProductProvider>(context, listen: false);
                  final effectiveFarmerName =
                      (auth.currentUser?.farmName != null && auth.currentUser!.farmName!.trim().isNotEmpty)
                          ? auth.currentUser!.farmName!
                          : (auth.currentUser?.name ?? 'Bashir Organic Farms');

                  final finalImageUrl = selectedBase64 ?? imageController.text.trim();

                  if (existingProduct == null) {
                    final newProd = ProductModel(
                      productId: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      farmerId: auth.currentUser?.uid ?? 'farmer_1',
                      itemName: nameController.text.trim(),
                      category: selectedCategory,
                      pricePerUnit: double.parse(priceController.text),
                      stockQty: int.parse(stockController.text),
                      imageUrl: finalImageUrl,
                      farmerName: effectiveFarmerName,
                      marketName: selectedMarket,
                    );
                    productProvider.addProduct(newProd);
                  } else {
                    final updated = existingProduct.copyWith(
                      itemName: nameController.text.trim(),
                      category: selectedCategory,
                      pricePerUnit: double.parse(priceController.text),
                      stockQty: int.parse(stockController.text),
                      imageUrl: finalImageUrl,
                      farmerName: effectiveFarmerName,
                      marketName: selectedMarket,
                    );
                    productProvider.updateProduct(updated);
                  }

                  Navigator.pop(ctx);
                  showHarvestSnackBar(
                    context,
                    message: existingProduct == null ? 'Product added successfully!' : 'Product updated!',
                    icon: existingProduct == null ? Icons.check_circle_rounded : Icons.edit_rounded,
                  );
                },
                child: Text(
                  existingProduct == null ? 'Add Product' : 'Save Changes',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Shows a dialog to add a new category. Returns the new category name or null.
  Future<String?> _showAddCategoryDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('New Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Spices, Pulses, Flowers...',
              prefixIcon: Icon(Icons.label_outline_rounded, color: AppColors.primary),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter a category name';
              final pp = Provider.of<ProductProvider>(context, listen: false);
              if (pp.categories.any((c) => c.toLowerCase() == v.trim().toLowerCase())) {
                return 'Category already exists';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.danger, size: 22),
            SizedBox(width: 8),
            Text('Delete Product?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.itemName}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
              productProvider.deleteProduct(product.productId);
              Navigator.pop(ctx);
              showHarvestSnackBar(
                context,
                message: '${product.itemName} deleted.',
                icon: Icons.delete_rounded,
                backgroundColor: AppColors.danger,
              );
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final farmerId = auth.currentUser?.uid ?? 'farmer_1';
    final farmerProducts = productProvider.getFarmerProducts(farmerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory & Product CRUD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${farmerProducts.length} items',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: PressableScale(
        onPressed: () => _showAddEditProductDialog(),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Crop Harvest',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      body: farmerProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                    child: const Icon(Icons.inventory_2_outlined, size: 42, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text('No Produce Items Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap "Add Crop Harvest" to list your\nfresh agricultural produce.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: farmerProducts.length,
              itemBuilder: (context, index) {
                final product = farmerProducts[index];
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Product Image
                        HarvestImage(
                          imageUrl: product.imageUrl,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          fallbackIcon: Icons.eco_rounded,
                        ),
                        const SizedBox(width: 12),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.itemName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
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
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Rs. ${product.pricePerUnit.toStringAsFixed(0)}/unit',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 7, height: 7,
                                    decoration: BoxDecoration(
                                      color: product.inStock ? AppColors.success : AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    product.inStock ? 'Stock: ${product.stockQty} units' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: product.inStock ? AppColors.success : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        Column(
                          children: [
                            PressableScale(
                              onPressed: () => _showAddEditProductDialog(product),
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.edit_rounded, color: AppColors.info, size: 17),
                              ),
                            ),
                            const SizedBox(height: 6),
                            PressableScale(
                              onPressed: () => _confirmDelete(context, product, productProvider),
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 17),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 280.ms, delay: Duration(milliseconds: index * 50)).slideY(begin: 0.04, end: 0);
              },
            ),
    );
  }
}
