import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/bid_model.dart';
import '../models/dispute_model.dart';
import '../app_config/constants.dart';
import 'mock_data.dart';

/// Firebase & Storage Service
/// Designed with standard repository pattern.
/// Persists data locally via SharedPreferences and provides direct
/// schema-compatible endpoints for Google Firebase Firestore & Auth sync.
class StorageService {
  static const String _keyUsers = 'harvesthub_users';
  static const String _keyProducts = 'harvesthub_products';
  static const String _keyOrders = 'harvesthub_orders';
  static const String _keyBids = 'harvesthub_bids';
  static const String _keyDisputes = 'harvesthub_disputes';
  static const String _keyCommission = 'harvesthub_commission_rate';
  static const String _keyLanguage = 'harvesthub_is_urdu';
  static const String _keyCurrentUserId = 'harvesthub_current_user_id';
  static const String _keyCurrentUser = 'harvesthub_current_user_profile';
  static const String _keyUserPasswords = 'harvesthub_user_passwords';
  // Cart persistence
  static const String _keyCart = 'harvesthub_cart';
  static const String _keyCartSelected = 'harvesthub_cart_selected';
  // Wishlist & social persistence
  static const String _keyWishlist = 'harvesthub_wishlist';
  static const String _keyFollowedFarmers = 'harvesthub_followed_farmers';
  static const String _keyCategories = 'harvesthub_categories';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs?.getString(_keyUserPasswords) == null) {
      final initialPasswords = {
        'admin@harvesthub.com': 'admin123',
        'tariq.buyer@gmail.com': '123456',
        'bashir.farmer@harvesthub.pk': '123456',
      };
      await _prefs?.setString(_keyUserPasswords, jsonEncode(initialPasswords));
    }
  }

  // Session persistence
  static String? getCurrentUserId() {
    return _prefs?.getString(_keyCurrentUserId);
  }

  static Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs?.remove(_keyCurrentUserId);
      await _prefs?.remove(_keyCurrentUser);
    } else {
      await _prefs?.setString(_keyCurrentUserId, userId);
    }
  }

  static UserModel? getCurrentUser() {
    final raw = _prefs?.getString(_keyCurrentUser);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(raw);
        return UserModel.fromMap(map);
      } catch (_) {}
    }
    final uid = getCurrentUserId();
    if (uid != null) {
      final users = loadUsers();
      try {
        return users.firstWhere((u) => u.uid == uid);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> setCurrentUser(UserModel? user) async {
    if (user == null) {
      await _prefs?.remove(_keyCurrentUser);
      await _prefs?.remove(_keyCurrentUserId);
    } else {
      await _prefs?.setString(_keyCurrentUser, jsonEncode(user.toMap()));
      await _prefs?.setString(_keyCurrentUserId, user.uid);
    }
  }

  // Password persistence for authenticated accounts
  static String? getUserPassword(String email) {
    final raw = _prefs?.getString(_keyUserPasswords);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      return map[email.trim().toLowerCase()] as String?;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------
  // Cart persistence — stores productId + quantity pairs
  // ---------------------------------------------------
  static List<CartItemModel> loadCart() {
    final raw = _prefs?.getString(_keyCart);
    if (raw == null) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<CartItemModel> items) async {
    final list = items.map((i) => i.toMap()).toList();
    await _prefs?.setString(_keyCart, jsonEncode(list));
  }

  // ---------------------------------------------------
  // Cart selected IDs persistence
  // ---------------------------------------------------
  static Set<String> loadCartSelectedIds() {
    final raw = _prefs?.getString(_keyCartSelected);
    if (raw == null) return {};
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCartSelectedIds(Set<String> ids) async {
    await _prefs?.setString(_keyCartSelected, jsonEncode(ids.toList()));
  }

  // ---------------------------------------------------
  // Wishlist persistence (list of product IDs)
  // ---------------------------------------------------
  static Set<String> loadWishlist() {
    final raw = _prefs?.getString(_keyWishlist);
    if (raw == null) return {};
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveWishlist(Set<String> productIds) async {
    await _prefs?.setString(_keyWishlist, jsonEncode(productIds.toList()));
  }

  // ---------------------------------------------------
  // Followed farmers persistence (list of farmer IDs)
  // ---------------------------------------------------
  static Set<String> loadFollowedFarmers() {
    final raw = _prefs?.getString(_keyFollowedFarmers);
    // Default: follow farmer_1 on first launch
    if (raw == null) return {'farmer_1'};
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<String>().toSet();
    } catch (_) {
      return {'farmer_1'};
    }
  }

  static Future<void> saveFollowedFarmers(Set<String> farmerIds) async {
    await _prefs?.setString(_keyFollowedFarmers, jsonEncode(farmerIds.toList()));
  }

  static Future<void> setUserPassword(String email, String password) async {
    Map<String, dynamic> map = {};
    final raw = _prefs?.getString(_keyUserPasswords);
    if (raw != null) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {}
    }
    map[email.trim().toLowerCase()] = password;
    await _prefs?.setString(_keyUserPasswords, jsonEncode(map));
  }

  // Language setting
  static bool getIsUrdu() {
    return _prefs?.getBool(_keyLanguage) ?? false;
  }

  static Future<void> setIsUrdu(bool value) async {
    await _prefs?.setBool(_keyLanguage, value);
  }

  // Commission rate (default 3%)
  static double getCommissionRate() {
    return _prefs?.getDouble(_keyCommission) ?? 3.0;
  }

  static Future<void> setCommissionRate(double rate) async {
    await _prefs?.setDouble(_keyCommission, rate);
  }

  // Users
  static List<UserModel> loadUsers() {
    final raw = _prefs?.getString(_keyUsers);
    if (raw == null) {
      final initial = MockData.initialUsers;
      saveUsers(initial);
      return initial;
    }
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => UserModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return MockData.initialUsers;
    }
  }

  static Future<void> saveUsers(List<UserModel> users) async {
    final list = users.map((u) => u.toMap()).toList();
    await _prefs?.setString(_keyUsers, jsonEncode(list));
  }

  // Products
  static List<ProductModel> loadProducts() {
    final raw = _prefs?.getString(_keyProducts);
    if (raw == null) {
      final initial = MockData.initialProducts;
      saveProducts(initial);
      return initial;
    }
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => ProductModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return MockData.initialProducts;
    }
  }

  static Future<void> saveProducts(List<ProductModel> products) async {
    final list = products.map((p) => p.toMap()).toList();
    await _prefs?.setString(_keyProducts, jsonEncode(list));
  }

  // Orders
  static List<OrderModel> loadOrders() {
    final raw = _prefs?.getString(_keyOrders);
    if (raw == null) {
      final initial = MockData.initialOrders;
      saveOrders(initial);
      return initial;
    }
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => OrderModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return MockData.initialOrders;
    }
  }

  static Future<void> saveOrders(List<OrderModel> orders) async {
    final list = orders.map((o) => o.toMap()).toList();
    await _prefs?.setString(_keyOrders, jsonEncode(list));
  }

  // Bids
  static List<BidModel> loadBids() {
    final raw = _prefs?.getString(_keyBids);
    if (raw == null) {
      final initial = MockData.initialBids;
      saveBids(initial);
      return initial;
    }
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => BidModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return MockData.initialBids;
    }
  }

  static Future<void> saveBids(List<BidModel> bids) async {
    final list = bids.map((b) => b.toMap()).toList();
    await _prefs?.setString(_keyBids, jsonEncode(list));
  }

  // Disputes
  static List<DisputeModel> loadDisputes() {
    final raw = _prefs?.getString(_keyDisputes);
    if (raw == null) {
      final initial = MockData.initialDisputes;
      saveDisputes(initial);
      return initial;
    }
    try {
      final List list = jsonDecode(raw);
      return list.map((item) => DisputeModel.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return MockData.initialDisputes;
    }
  }

  static Future<void> saveDisputes(List<DisputeModel> disputes) async {
    final list = disputes.map((d) => d.toMap()).toList();
    await _prefs?.setString(_keyDisputes, jsonEncode(list));
  }

  // Categories
  static List<String> loadCategories() {
    final raw = _prefs?.getStringList(_keyCategories);
    if (raw == null || raw.isEmpty) {
      saveCategories(AppConstants.categories);
      return List<String>.from(AppConstants.categories);
    }
    return List<String>.from(raw);
  }

  static Future<void> saveCategories(List<String> categories) async {
    await _prefs?.setStringList(_keyCategories, categories);
  }

  // Platform Charges / Fee (Admin Configurable)
  static const String _keyPlatformFee = 'harvesthub_platform_fee';

  static double getPlatformFee() {
    return _prefs?.getDouble(_keyPlatformFee) ?? 20.0;
  }

  static Future<void> setPlatformFee(double fee) async {
    await _prefs?.setDouble(_keyPlatformFee, fee);
  }
}

