import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';
import '../models/farmer_model.dart';
import '../models/market_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<FarmerModel> _farmers = [];
  List<MarketModel> _markets = [];
  List<String> _categories = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedMarketFilter = 'All';
  String _selectedLocationFilter = 'All';

  // Location & Distance Calculation State
  String _userCity = 'Faisalabad';
  double _userLat = 31.4187;
  double _userLon = 73.0791;
  double? _maxDistanceKm; // null means All distances
  bool _sortByNearest = false;

  final Set<String> _wishlistProductIds = {};
  final Set<String> _followedFarmerIds = {'farmer_1'};
  final Set<String> _restockAlertProductIds = {};

  final List<Map<String, dynamic>> _inAppNotifications = [
    {
      'id': 'notif_1',
      'title': 'Welcome to HarvestHub! 🌾',
      'message': 'Fresh local farm produce available directly from verified farmers without middlemen.',
      'time': 'Just now',
      'read': false,
      'type': 'welcome',
    },
    {
      'id': 'notif_2',
      'title': 'Restock Alert: Organic Tomatoes 🍅',
      'message': 'Bashir Green Organic Farms restocked 50 fresh units of Red Tomatoes at Faisalabad Model Mandi.',
      'time': '2 hours ago',
      'read': false,
      'type': 'restock',
    },
    {
      'id': 'notif_3',
      'title': 'Order Status Update 📦',
      'message': 'Order #ord_1001 has been completed. Thank you for supporting local farmers!',
      'time': 'Yesterday',
      'read': true,
      'type': 'order',
    },
  ];

  Timer? _firestoreDebounce;

  ProductProvider() {
    _loadInitialData();
  }

  List<ProductModel> get products => _products;
  List<FarmerModel> get farmers => _farmers;
  List<MarketModel> get markets => _markets;
  List<String> get categories => List.unmodifiable(_categories);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedMarketFilter => _selectedMarketFilter;
  String get selectedLocationFilter => _selectedLocationFilter;
  String get userCity => _userCity;
  double? get maxDistanceKm => _maxDistanceKm;
  bool get sortByNearest => _sortByNearest;
  Set<String> get wishlistProductIds => _wishlistProductIds;
  Set<String> get followedFarmerIds => _followedFarmerIds;
  Set<String> get restockAlertProductIds => _restockAlertProductIds;
  List<Map<String, dynamic>> get inAppNotifications => _inAppNotifications;
  int get unreadNotificationCount => _inAppNotifications.where((n) => n['read'] == false).length;

  /// All unique market names / locations for the location filter
  List<String> get availableLocations {
    final locs = _products
        .map((p) => p.marketName ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    locs.sort();
    return locs;
  }

  void _loadInitialData() {
    _products = StorageService.loadProducts();
    if (_products.isEmpty) {
      _products = List.from(FirebaseService.seedProducts);
      StorageService.saveProducts(_products);
    }
    _categories = StorageService.loadCategories();
    _farmers = List.from(FirebaseService.seedFarmers);
    _markets = List.from(FirebaseService.seedMarkets);
    _wishlistProductIds.clear();
    _wishlistProductIds.addAll(StorageService.loadWishlist());
    _followedFarmerIds.clear();
    _followedFarmerIds.addAll(StorageService.loadFollowedFarmers());
    notifyListeners();

    // Asynchronously synchronize with Cloud Firestore
    _syncWithFirestore();
  }

  Future<void> _syncWithFirestore() async {
    try {
      // 1. Ensure initial cloud collections exist
      await FirebaseService.seedAllCollectionsToFirestore();

      // 2. Fetch products from Firestore
      final remoteProducts = await FirebaseService.fetchProducts();
      if (remoteProducts.isNotEmpty) {
        _products = remoteProducts;
        await StorageService.saveProducts(_products);
        notifyListeners();
      }

      // 3. Fetch categories from Firestore
      final catSnap = await FirebaseFirestore.instance.collection('categories').get();
      if (catSnap.docs.isNotEmpty) {
        final remoteCats = catSnap.docs
            .map((d) => (d.data()['name'] ?? '').toString())
            .where((n) => n.isNotEmpty)
            .toList();
        if (remoteCats.isNotEmpty) {
          _categories = remoteCats;
          await StorageService.saveCategories(_categories);
          notifyListeners();
        }
      }

      // 4. Fetch farmers & markets
      final remoteFarmers = await FirebaseService.fetchFarmers();
      if (remoteFarmers.isNotEmpty) {
        _farmers = remoteFarmers;
        notifyListeners();
      }
      final remoteMarkets = await FirebaseService.fetchMarkets();
      if (remoteMarkets.isNotEmpty) {
        _markets = remoteMarkets;
        notifyListeners();
      }

      // 5. Continuous real-time synchronization with Cloud Firestore (debounced)
      FirebaseService.productsStream().listen((remoteProducts) {
        if (remoteProducts.isEmpty) return;
        // Debounce: wait 800ms after last update before notifying UI
        _firestoreDebounce?.cancel();
        _firestoreDebounce = Timer(const Duration(milliseconds: 800), () {
          // Only notify if data actually changed (compare product IDs)
          final oldIds = _products.map((p) => p.productId).toSet();
          final newIds = remoteProducts.map((p) => p.productId).toSet();
          final hasChanges = oldIds.length != newIds.length ||
              !oldIds.containsAll(newIds) ||
              _productsDataChanged(_products, remoteProducts);
          if (hasChanges) {
            _products = remoteProducts;
            StorageService.saveProducts(_products);
            notifyListeners();
          }
        });
      }, onError: (_) {});
    } catch (_) {}
  }

  /// Check if any product's key fields changed (to avoid unnecessary rebuilds)
  bool _productsDataChanged(List<ProductModel> oldList, List<ProductModel> newList) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      final o = oldList[i];
      final n = newList[i];
      if (o.productId != n.productId ||
          o.itemName != n.itemName ||
          o.pricePerUnit != n.pricePerUnit ||
          o.stockQty != n.stockQty ||
          o.imageUrl != n.imageUrl) {
        return true;
      }
    }
    return false;
  }

  /// Categories Management — persisted to StorageService and synced with Firestore
  Future<void> addCategory(String categoryName) async {
    final trimmed = categoryName.trim();
    if (trimmed.isEmpty || _categories.contains(trimmed)) return;

    _categories.add(trimmed);
    await StorageService.saveCategories(_categories);
    notifyListeners();

    try {
      final docId = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      await FirebaseFirestore.instance.collection('categories').doc(docId).set({
        'name': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> deleteCategory(String categoryName) async {
    final trimmed = categoryName.trim();
    _categories.remove(trimmed);
    if (_selectedCategory == trimmed) {
      _selectedCategory = 'All';
    }
    await StorageService.saveCategories(_categories);
    notifyListeners();

    try {
      final docId = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
    } catch (_) {}
  }

  int getProductCountForCategory(String categoryName) {
    if (categoryName == 'All') return _products.length;
    return _products.where((p) => p.category.toLowerCase() == categoryName.toLowerCase()).length;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMarketFilter(String marketName) {
    _selectedMarketFilter = marketName;
    notifyListeners();
  }

  void setLocationFilter(String location) {
    _selectedLocationFilter = location;
    notifyListeners();
  }

  void setUserCity(String city) {
    _userCity = city;
    switch (city.toLowerCase()) {
      case 'lahore':
        _userLat = 31.5204;
        _userLon = 74.3587;
        break;
      case 'multan':
        _userLat = 30.1575;
        _userLon = 71.5249;
        break;
      case 'rawalpindi':
      case 'islamabad':
        _userLat = 33.6007;
        _userLon = 73.0679;
        break;
      case 'faisalabad':
      default:
        _userLat = 31.4187;
        _userLon = 73.0791;
        break;
    }
    notifyListeners();
  }

  void setMaxDistanceKm(double? km) {
    _maxDistanceKm = km;
    notifyListeners();
  }

  void setSortByNearest(bool value) {
    _sortByNearest = value;
    notifyListeners();
  }

  /// Calculates realistic distance (in KM) between user GPS and the product's Mandi
  double getProductDistanceKm(ProductModel product) {
    double mLat = 31.4187;
    double mLon = 73.0791;
    final mName = (product.marketName ?? '').toLowerCase();

    if (mName.contains('lahore')) {
      mLat = 31.4697;
      mLon = 74.2728;
    } else if (mName.contains('multan')) {
      mLat = 30.1575;
      mLon = 71.5249;
    } else if (mName.contains('rawalpindi') || mName.contains('islamabad')) {
      mLat = 33.6007;
      mLon = 73.0679;
    } else {
      mLat = 31.4187;
      mLon = 73.0791;
    }

    const p = 0.017453292519943295; // Pi / 180
    final a = 0.5 -
        math.cos((mLat - _userLat) * p) / 2 +
        math.cos(_userLat * p) *
            math.cos(mLat * p) *
            (1 - math.cos((mLon - _userLon) * p)) /
            2;
    final dist = 12742 * math.asin(math.sqrt(a));

    if (dist < 1.0) {
      final offset = (product.productId.hashCode.abs() % 40) / 10.0;
      return 1.8 + offset;
    }
    return double.parse(dist.toStringAsFixed(1));
  }

  /// Filtered product catalog according to Search, Category, Market, Location & Distance filters
  List<ProductModel> get filteredProducts {
    var list = _products.where((prod) {
      final matchesCategory = _selectedCategory == 'All' ||
          prod.category.toLowerCase().trim() ==
              _selectedCategory.toLowerCase().trim();
      final matchesMarket = _selectedMarketFilter == 'All' ||
          (prod.marketName != null &&
              prod.marketName!.contains(_selectedMarketFilter));
      final matchesLocation = _selectedLocationFilter == 'All' ||
          (prod.marketName != null &&
              prod.marketName!.contains(_selectedLocationFilter));

      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          prod.itemName.toLowerCase().contains(q) ||
          prod.category.toLowerCase().contains(q) ||
          (prod.farmerName != null &&
              prod.farmerName!.toLowerCase().contains(q)) ||
          (prod.marketName != null &&
              prod.marketName!.toLowerCase().contains(q));

      final dist = getProductDistanceKm(prod);
      final matchesDistance = _maxDistanceKm == null || dist <= _maxDistanceKm!;

      return matchesCategory && matchesMarket && matchesLocation && matchesQuery && matchesDistance;
    }).toList();

    if (_sortByNearest) {
      list.sort((a, b) => getProductDistanceKm(a).compareTo(getProductDistanceKm(b)));
    }

    return list;
  }

  /// Wishlist Management
  bool isInWishlist(String productId) => _wishlistProductIds.contains(productId);

  void toggleWishlist(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    StorageService.saveWishlist(_wishlistProductIds);
    notifyListeners();
  }

  List<ProductModel> get wishlistProducts {
    return _products.where((p) => _wishlistProductIds.contains(p.productId)).toList();
  }

  /// Follow/Favorite Farmer Management
  bool isFollowingFarmer(String farmerId) => _followedFarmerIds.contains(farmerId);

  void toggleFollowFarmer(String farmerId) {
    if (_followedFarmerIds.contains(farmerId)) {
      _followedFarmerIds.remove(farmerId);
    } else {
      _followedFarmerIds.add(farmerId);
    }
    StorageService.saveFollowedFarmers(_followedFarmerIds);
    notifyListeners();
  }

  /// Farmer Inventory CRUD Operations
  List<ProductModel> getFarmerProducts(String farmerId) {
    return _products.where((p) => p.farmerId == farmerId || farmerId == 'farmer_1').toList();
  }

  void addProduct(ProductModel newProduct) {
    _products.insert(0, newProduct);
    StorageService.saveProducts(_products);
    notifyListeners();
    FirebaseService.saveProduct(newProduct);
  }

  void updateProduct(ProductModel updatedProduct) {
    final idx = _products.indexWhere((p) => p.productId == updatedProduct.productId);
    if (idx != -1) {
      _products[idx] = updatedProduct;
      StorageService.saveProducts(_products);
      notifyListeners();
      FirebaseService.saveProduct(updatedProduct);
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.productId == productId);
    _wishlistProductIds.remove(productId);
    StorageService.saveWishlist(_wishlistProductIds);
    StorageService.saveProducts(_products);
    notifyListeners();
    FirebaseService.deleteProduct(productId);
  }

  void updateStock(String productId, int newStock) {
    final idx = _products.indexWhere((p) => p.productId == productId);
    if (idx != -1) {
      final oldStock = _products[idx].stockQty;
      _products[idx] = _products[idx].copyWith(stockQty: newStock);
      StorageService.saveProducts(_products);
      FirebaseService.updateProductStock(productId, newStock);

      // Trigger Restock Notification if old stock was 0 and now restocked
      if (oldStock == 0 && newStock > 0 && _restockAlertProductIds.contains(productId)) {
        addNotification(
          title: 'Restock Alert: ${_products[idx].itemName} 🎉',
          message: '${_products[idx].itemName} has been restocked with $newStock units by ${_products[idx].farmerName ?? "farmer"}.',
          type: 'restock',
        );
      }
      notifyListeners();
    }
  }

  /// Restock Alerts Subscription
  bool hasRestockAlert(String productId) => _restockAlertProductIds.contains(productId);

  void toggleRestockAlert(String productId, {String? productName}) {
    if (_restockAlertProductIds.contains(productId)) {
      _restockAlertProductIds.remove(productId);
    } else {
      _restockAlertProductIds.add(productId);
      addNotification(
        title: 'Restock Alert Active 🔔',
        message: 'You will receive an instant notification when ${productName ?? "this harvest product"} is restocked.',
        type: 'restock',
      );
    }
    notifyListeners();
  }

  /// In-App Notifications Management
  void markNotificationsRead() {
    for (var n in _inAppNotifications) {
      n['read'] = true;
    }
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    _inAppNotifications.insert(0, {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'message': message,
      'time': 'Just now',
      'read': false,
      'type': type,
    });
    notifyListeners();
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < _inAppNotifications.length) {
      _inAppNotifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _inAppNotifications.clear();
    notifyListeners();
  }
}
