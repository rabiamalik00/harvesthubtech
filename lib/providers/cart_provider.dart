import 'package:flutter/material.dart';
import '../models/cart_item_model.dart' as db_cart;
import '../models/product_model.dart';
import '../services/storage_service.dart';

/// In-memory cart item that holds a full ProductModel reference for UI display.
class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.pricePerUnit * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  final Set<String> _selectedIds = {};

  CartProvider() {
    restoreFromStorage();
  }

  // ── Public getters ───────────────────────────────────────────────────────
  Map<String, CartItemModel> get items => _items;
  List<CartItemModel> get itemList => _items.values.toList();
  Set<String> get selectedIds => _selectedIds;
  int get itemCount => _items.length;

  List<CartItemModel> get selectedItems =>
      _items.values.where((i) => _selectedIds.contains(i.product.productId)).toList();

  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get selectedTotalAmount =>
      selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get allSelected =>
      _items.isNotEmpty && _selectedIds.length == _items.length;

  bool isSelected(String productId) => _selectedIds.contains(productId);

  // ── Initialise: restore cart from local storage ──────────────────────────
  /// Restores cart from SharedPreferences using the product catalog.
  void restoreFromStorage([List<ProductModel>? allProducts]) {
    final catalog = (allProducts != null && allProducts.isNotEmpty)
        ? allProducts
        : StorageService.loadProducts();
    final savedItems = StorageService.loadCart();
    final savedSelected = StorageService.loadCartSelectedIds();

    _items.clear();
    _selectedIds.clear();

    for (final saved in savedItems) {
      try {
        final product = catalog.firstWhere(
          (p) => p.productId == saved.productId,
        );
        _items[product.productId] = CartItemModel(
          product: product,
          quantity: saved.quantity,
        );
      } catch (_) {
        // Product no longer exists in catalog — skip it silently
      }
    }

    // Restore selected IDs (only for items that are still in cart)
    for (final id in savedSelected) {
      if (_items.containsKey(id)) {
        _selectedIds.add(id);
      }
    }

    notifyListeners();
  }

  // ── Persist helpers ──────────────────────────────────────────────────────
  void _persist() {
    final toSave = _items.values
        .map((i) => db_cart.CartItemModel(
              productId: i.product.productId,
              quantity: i.quantity,
            ))
        .toList();
    StorageService.saveCart(toSave);
    StorageService.saveCartSelectedIds(_selectedIds);
  }

  // ── Selection management ─────────────────────────────────────────────────
  void toggleSelection(String productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
    }
    _persist();
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(_items.keys);
    _persist();
    notifyListeners();
  }

  void deselectAll() {
    _selectedIds.clear();
    _persist();
    notifyListeners();
  }

  void toggleSelectAll() {
    if (allSelected) {
      deselectAll();
    } else {
      selectAll();
    }
  }

  // ── Cart CRUD ────────────────────────────────────────────────────────────
  /// Returns an error string on failure, or null on success.
  String? addToCart(ProductModel product, {int quantity = 1}) {
    if (product.stockQty <= 0) {
      return 'Out of Stock: ${product.itemName} is currently unavailable.';
    }

    if (_items.containsKey(product.productId)) {
      final existing = _items[product.productId]!;
      if (existing.quantity + quantity > product.stockQty) {
        return 'Cannot add more than ${product.stockQty} units (stock limit).';
      }
      existing.quantity += quantity;
    } else {
      _items[product.productId] = CartItemModel(
        product: product,
        quantity: quantity,
      );
      // Auto-select newly added items
      _selectedIds.add(product.productId);
    }
    _persist();
    notifyListeners();
    return null;
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < item.product.stockQty) {
        item.quantity++;
        _persist();
        notifyListeners();
      }
    }
  }

  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _items.remove(productId);
        _selectedIds.remove(productId);
      }
      _persist();
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _selectedIds.remove(productId);
    _persist();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedIds.clear();
    _persist();
    notifyListeners();
  }
}
