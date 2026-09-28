import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

class CartItem {
  final ProductModel product;
  int quantityKg;

  CartItem({
    required this.product,
    this.quantityKg = 1,
  });

  double get unitPrice => product.pricePerKg;
  double get subtotal => unitPrice * quantityKg;
  double get discountPercent => Formatters.getBulkDiscountPercent(quantityKg);
  double get discountAmount => subtotal * discountPercent;
  double get total => subtotal - discountAmount;
}

class MarketplaceProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  final Map<String, CartItem> _cart = {};

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedDistrict = 'All';

  List<ProductModel> get products => _products;
  Map<String, CartItem> get cart => _cart;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedDistrict => _selectedDistrict;

  MarketplaceProvider() {
    loadProducts();
  }

  void loadProducts() {
    _products = StorageService.loadProducts();
    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          (_selectedCategory == 'Organic' ? p.isOrganic : p.category.toLowerCase() == _selectedCategory.toLowerCase());

      final matchesDistrict = _selectedDistrict == 'All' ||
          p.district.toLowerCase() == _selectedDistrict.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.district.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.farmerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return matchesCategory && matchesDistrict && matchesQuery;
    }).toList();
  }

  List<ProductModel> getFarmerProducts(String farmerId) {
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void addProduct(ProductModel product) {
    _products.insert(0, product);
    StorageService.saveProducts(_products);
    notifyListeners();
  }

  void updateProduct(ProductModel product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    StorageService.saveProducts(_products);
    notifyListeners();
  }

  void toggleProductOrganic(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      // Toggle: if currently Organic, flip to Vegetables; otherwise set to Organic
      final newCategory = p.isOrganic ? 'Vegetables' : 'Organic';
      _products[index] = p.copyWith(category: newCategory);
      StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  void adminUpdateProduct(String productId,
      {double? pricePerKg, int? stockKg, bool? isOrganic}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      _products[index] = p.copyWith(
        pricePerUnit: pricePerKg,
        stockQty: stockKg,
        category: isOrganic != null
            ? (isOrganic ? 'Organic' : p.category)
            : p.category,
      );
      StorageService.saveProducts(_products);
      notifyListeners();
    }
  }

  // Cart Management
  int get cartCount => _cart.values.fold(0, (sum, item) => sum + item.quantityKg);

  double get cartSubtotal => _cart.values.fold(0.0, (sum, item) => sum + item.subtotal);

  double get cartDiscount => _cart.values.fold(0.0, (sum, item) => sum + item.discountAmount);

  double get cartNetSubtotal => cartSubtotal - cartDiscount;

  double get cartPlatformFee => cartNetSubtotal * 0.03;

  double get cartTotal => cartNetSubtotal + cartPlatformFee;

  void addToCart(ProductModel product, {int quantity = 1}) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantityKg += quantity;
    } else {
      _cart[product.id] = CartItem(product: product, quantityKg: quantity);
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    if (_cart.containsKey(productId)) {
      if (quantity <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId]!.quantityKg = quantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
