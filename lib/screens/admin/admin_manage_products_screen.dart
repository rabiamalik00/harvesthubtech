import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_config/theme.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/harvest_image.dart';

class AdminManageProductsScreen extends StatefulWidget {
  const AdminManageProductsScreen({super.key});

  @override
  State<AdminManageProductsScreen> createState() =>
      _AdminManageProductsScreenState();
}

class _AdminManageProductsScreenState
    extends State<AdminManageProductsScreen> {
  String _search = '';

  // ─── Full Edit Bottom Sheet ───────────────────────────────────────────────
  void _openEditSheet(BuildContext context, ProductModel product) {
    final nameCtrl = TextEditingController(text: product.itemName);
    final priceCtrl =
        TextEditingController(text: product.pricePerUnit.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: product.stockQty.toString());
    final farmerCtrl = TextEditingController(text: product.farmerName ?? '');
    final marketCtrl = TextEditingController(text: product.marketName ?? '');
    final descCtrl = TextEditingController(text: product.description ?? '');
    final locationCtrl =
        TextEditingController(text: product.farmLocation ?? '');

    String selectedCategory = product.category;
    String? newImageBase64; // holds newly picked image as base64 data URI
    Uint8List? previewBytes; // for in-sheet preview
    final formKey = GlobalKey<FormState>();

    final categories = [
      'Vegetables',
      'Fruits',
      'Grains',
      'Dairy',
      'Herbs',
      'Organic',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickImage(ImageSource source) async {
              final picker = ImagePicker();
              final picked =
                  await picker.pickImage(source: source, imageQuality: 75);
              if (picked == null) return;
              final bytes = await picked.readAsBytes();
              final base64Str = base64Encode(bytes);
              final ext = picked.path.split('.').last.toLowerCase();
              final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
              setSheetState(() {
                previewBytes = bytes;
                newImageBase64 = 'data:$mime;base64,$base64Str';
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.92,
              minChildSize: 0.5,
              maxChildSize: 0.97,
              expand: false,
              builder: (_, scrollCtrl) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Handle
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.purple, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Edit Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Scrollable Form
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Image Upload Section ──────────────────────
                              _sectionLabel('Product Image'),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current / New image preview
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: previewBytes != null
                                        ? Image.memory(
                                            previewBytes!,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          )
                                        : HarvestImage(
                                            imageUrl: product.imageUrl,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            fallbackIcon: Icons.eco_rounded,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tap an icon to change the product image',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Camera
                                            _imagePickerButton(
                                              icon: Icons.camera_alt_rounded,
                                              label: 'Camera',
                                              color: Colors.purple,
                                              onTap: () => pickImage(
                                                  ImageSource.camera),
                                            ),
                                            const SizedBox(width: 10),
                                            // Gallery
                                            _imagePickerButton(
                                              icon: Icons.photo_library_rounded,
                                              label: 'Gallery',
                                              color: Colors.deepPurple,
                                              onTap: () => pickImage(
                                                  ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                        if (previewBytes != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 14,
                                                  color: AppColors.success),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'New image selected',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.success,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ── Product Name ─────────────────────────────
                              _sectionLabel('Product Name'),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: nameCtrl,
                                hint: 'e.g. Organic Red Tomatoes',
                                icon: Icons.eco_rounded,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Name is required'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // ── Category ──────────────────────────────────
                              _sectionLabel('Category'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: categories.contains(selectedCategory)
                                        ? selectedCategory
                                        : categories.first,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.purple),
                                    items: categories
                                        .map((c) => DropdownMenuItem(
                                            value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setSheetState(
                                            () => selectedCategory = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Price & Stock ────────────────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _sectionLabel('Price (Rs./unit)'),
                                        const SizedBox(height: 8),
                                        _buildField(
                                          controller: priceCtrl,
                                          hint: '0',
                                          icon: Icons.attach_money_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(v) == null ||
                                                double.parse(v) <= 0) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _sectionLabel('Stock (qty)'),
                                        const SizedBox(height: 8),
                                        _buildField(
                                          controller: stockCtrl,
                                          hint: '0',
                                          icon: Icons.inventory_2_outlined,
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Required';
                                            }
                                            if (int.tryParse(v) == null ||
                                                int.parse(v) < 0) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ── Farmer Name ──────────────────────────────
                              _sectionLabel('Farmer / Farm Name'),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: farmerCtrl,
                                hint: 'e.g. Bashir Organic Farms',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 16),

                              // ── Market Name ──────────────────────────────
                              _sectionLabel('Market / Mandi'),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: marketCtrl,
                                hint: 'e.g. Faisalabad Model Mandi',
                                icon: Icons.storefront_rounded,
                              ),
                              const SizedBox(height: 16),

                              // ── Farm Location ─────────────────────────────
                              _sectionLabel('Farm Location'),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: locationCtrl,
                                hint: 'e.g. Sahiwal, Punjab',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),

                              // ── Description ───────────────────────────────
                              _sectionLabel('Description'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: descCtrl,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Short product description (optional)...',
                                  hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textLight),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.purple, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 32),

                              // ── Save Button ───────────────────────────────
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.save_rounded,
                                      color: Colors.white),
                                  label: const Text(
                                    'Save All Changes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final pp = Provider.of<ProductProvider>(
                                        context,
                                        listen: false);

                                    pp.updateProduct(product.copyWith(
                                      itemName: nameCtrl.text.trim(),
                                      category: selectedCategory,
                                      pricePerUnit:
                                          double.parse(priceCtrl.text.trim()),
                                      stockQty:
                                          int.parse(stockCtrl.text.trim()),
                                      farmerName: farmerCtrl.text.trim().isEmpty
                                          ? product.farmerName
                                          : farmerCtrl.text.trim(),
                                      marketName: marketCtrl.text.trim().isEmpty
                                          ? product.marketName
                                          : marketCtrl.text.trim(),
                                      farmLocation:
                                          locationCtrl.text.trim().isEmpty
                                              ? product.farmLocation
                                              : locationCtrl.text.trim(),
                                      description: descCtrl.text.trim().isEmpty
                                          ? product.description
                                          : descCtrl.text.trim(),
                                      imageUrl: newImageBase64 ?? product.imageUrl,
                                    ));

                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 18),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${nameCtrl.text.trim()} updated successfully!',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.textLight),
        prefixIcon: Icon(icon, size: 18, color: Colors.purple),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  Widget _imagePickerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirmation ───────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Delete Product?'),
          ],
        ),
        content: Text(
            'Are you sure you want to remove "${product.itemName}" from the platform? This cannot be undone.',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.productId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${product.itemName} removed from platform.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<ProductProvider>(context);
    final products = pp.products
        .where((p) =>
            _search.isEmpty ||
            p.itemName.toLowerCase().contains(_search.toLowerCase()) ||
            (p.farmerName ?? '')
                .toLowerCase()
                .contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage All Products'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products or farmer...',
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textSecondary),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip(
                    'Total Products', '${products.length}', Colors.purple),
                const SizedBox(width: 8),
                _buildStatChip(
                    'In Stock',
                    '${products.where((p) => p.inStock).length}',
                    AppColors.success),
                const SizedBox(width: 8),
                _buildStatChip(
                    'Out of Stock',
                    '${products.where((p) => !p.inStock).length}',
                    AppColors.danger),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text('No products found',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Product Image
                              Stack(
                                children: [
                                  HarvestImage(
                                    imageUrl: product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(8),
                                    fallbackIcon: Icons.eco,
                                  ),
                                  // "No image" indicator
                                  if (product.imageUrl.isEmpty ||
                                      product.imageUrl.startsWith('https://') &&
                                          product.imageUrl.isEmpty)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.purple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.add_photo_alternate_rounded,
                                            size: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(product.itemName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Text(
                                        product.farmerName ??
                                            'Unknown Farmer',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Wrap(
                                       spacing: 6,
                                       runSpacing: 3,
                                       crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                            'Rs. ${product.pricePerUnit.toStringAsFixed(0)}/unit',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: product.inStock
                                                ? AppColors.success
                                                    .withValues(alpha: 0.12)
                                                : AppColors.danger
                                                    .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            product.inStock
                                                ? 'Stock: ${product.stockQty}'
                                                : 'Out of Stock',
                                            style: TextStyle(
                                              color: product.inStock
                                                  ? AppColors.success
                                                  : AppColors.danger,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(product.category,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                              // Action Buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: Colors.purple),
                                    onPressed: () =>
                                        _openEditSheet(context, product),
                                    tooltip: 'Edit Product',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.danger),
                                    onPressed: () =>
                                        _confirmDelete(context, product),
                                    tooltip: 'Delete Product',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}