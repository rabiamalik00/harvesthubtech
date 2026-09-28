import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_config/constants.dart';
import '../../models/farmer_model.dart';
import '../../models/market_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/support_query_model.dart';
import '../../models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionSupportQueries = 'support_queries';
  static const String collectionCustomerReviews = 'customer_reviews';

  // Initial Mock Database Seed Data for Offline / Pre-populated App State
  static final List<UserModel> seedUsers = [
    UserModel(
      uid: 'user_cust_1',
      name: 'Tariq Mehmood',
      email: 'tariq.buyer@gmail.com',
      phone: '+92 300 1112233',
      role: AppConstants.roleCustomer,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      uid: 'user_farm_1',
      name: 'Kisaan Bashir Ahmad',
      email: 'bashir.farmer@harvesthub.pk',
      phone: '+92 300 4445566',
      role: AppConstants.roleFarmer,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      farmName: 'Bashir Green Organic Farms',
      marketName: 'Faisalabad Model Mandi Market',
      address: 'Chak 208 RB, Canal Road, Faisalabad',
    ),
    UserModel(
      uid: 'admin_root',
      name: 'Platform Administrator',
      email: 'admin@harvesthub.com',
      phone: '+92 300 0000000',
      role: AppConstants.roleAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  static final List<FarmerModel> seedFarmers = [
    FarmerModel(
      farmerId: 'farmer_1',
      userId: 'user_farm_1',
      marketId: 'market_1',
      businessName: 'Bashir Green Organic Farms',
      description: 'Certified fresh organic vegetables and fruits grown in Faisalabad.',
      rating: 4.9,
      followers: ['user_cust_1'],
    ),
    FarmerModel(
      farmerId: 'farmer_2',
      userId: 'user_farm_2',
      marketId: 'market_2',
      businessName: 'Punjab Pure Dairy & Grains',
      description: 'Pure buffalo milk, artisan butter, and premium Basmati rice.',
      rating: 4.7,
      followers: [],
    ),
  ];

  static final List<MarketModel> seedMarkets = [
    MarketModel(
      marketId: 'market_1',
      marketName: 'Faisalabad Model Mandi Market',
      address: 'Main Canal Road, Faisalabad',
      gpsCoordinates: const GeoPoint(31.4187, 73.0791),
      operatingHours: '08:00 AM - 06:00 PM',
      activeStatus: true,
    ),
    MarketModel(
      marketId: 'market_2',
      marketName: 'Lahore Model Agriculture Bazaar',
      address: 'Johar Town Mandi Complex, Lahore',
      gpsCoordinates: const GeoPoint(31.4697, 74.2728),
      operatingHours: '07:00 AM - 07:00 PM',
      activeStatus: true,
    ),
  ];

  static final List<ProductModel> seedProducts = [
    ProductModel(
      productId: 'prod_1',
      farmerId: 'farmer_1',
      itemName: 'Organic Red Tomatoes',
      category: 'Vegetables',
      pricePerUnit: 140.0,
      stockQty: 50,
      imageUrl: 'https://images.unsplash.com/photo-1546470427-e26264be0b11?w=500',
      farmerName: 'Bashir Green Organic Farms',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_2',
      farmerId: 'farmer_1',
      itemName: 'Fresh Spinach (Palak)',
      category: 'Organic',
      pricePerUnit: 60.0,
      stockQty: 30,
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500',
      farmerName: 'Bashir Green Organic Farms',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_3',
      farmerId: 'farmer_1',
      itemName: 'Farm Fresh Oranges (Kinnow)',
      category: 'Fruits',
      pricePerUnit: 220.0,
      stockQty: 100,
      imageUrl: 'https://images.unsplash.com/photo-1547514701-42782101795e?w=500',
      farmerName: 'Bashir Green Organic Farms',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_4',
      farmerId: 'farmer_2',
      itemName: 'Super Kernel Basmati Rice (5kg)',
      category: 'Grains',
      pricePerUnit: 1650.0,
      stockQty: 25,
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
      farmerName: 'Punjab Pure Dairy & Grains',
      marketName: 'Lahore Model Agriculture Bazaar',
    ),
    ProductModel(
      productId: 'prod_5',
      farmerId: 'farmer_2',
      itemName: 'Pure Farm Milk',
      category: 'Dairy',
      pricePerUnit: 210.0,
      unit: 'kg',
      stockQty: 40,
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500',
      farmerName: 'Punjab Pure Dairy & Grains',
      marketName: 'Lahore Model Agriculture Bazaar',
    ),
  ];

  static final List<OrderModel> seedOrders = [
    OrderModel(
      orderId: 'ord_1001',
      customerId: 'user_cust_1',
      farmerId: 'farmer_1',
      items: [
        OrderItemModel(productId: 'prod_1', itemName: 'Organic Red Tomatoes', quantity: 2, pricePerUnit: 140.0),
        OrderItemModel(productId: 'prod_2', itemName: 'Fresh Spinach (Palak)', quantity: 1, pricePerUnit: 60.0),
      ],
      pickupSlotTime: '10:00 AM - 12:00 PM',
      status: AppConstants.statusCompleted,
      totalPrice: 340.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      customerName: 'Tariq Mehmood',
      farmerBusinessName: 'Bashir Green Organic Farms',
    ),
  ];

  // Auth Operations
  static User? get currentFirebaseUser => _auth.currentUser;

  static Future<UserModel?> fetchUserRecord(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {}
    // Seed fallback lookup
    try {
      return seedUsers.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserRecord(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<List<UserModel>> fetchUsers() async {
    try {
      final snap = await _firestore.collection(AppConstants.collectionUsers).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> deleteUserRecord(String uid) async {
    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(uid).delete();
    } catch (_) {}
  }

  // ===============================================================
  // Firestore Synchronization Methods (SRS Section 1.8 Compliance)
  // ===============================================================

  /// Products Collection (SRS Table 1.8.3)
  static Future<void> saveProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(product.productId)
          .set(product.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .delete();
    } catch (_) {}
  }

  static Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore
          .collection(AppConstants.collectionProducts)
          .doc(productId)
          .update({'stock_qty': newStock});
    } catch (_) {}
  }

  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final snap = await _firestore.collection(AppConstants.collectionProducts).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Orders Collection (SRS Table 1.8.4)
  static Future<void> saveOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(AppConstants.collectionOrders)
          .doc(order.orderId)
          .set(order.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection(AppConstants.collectionOrders)
          .doc(orderId)
          .update({'status': newStatus});
    } catch (_) {}
  }

  static Future<void> updateOrderPickupSlot(String orderId, String newSlot) async {
    try {
      await _firestore
          .collection(AppConstants.collectionOrders)
          .doc(orderId)
          .update({'pickup_slot_time': newSlot});
    } catch (_) {}
  }

  static Future<List<OrderModel>> fetchOrders() async {
    try {
      final snap = await _firestore.collection(AppConstants.collectionOrders).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Farmers Collection (SRS Table 1.8.2)
  static Future<void> saveFarmer(FarmerModel farmer) async {
    try {
      await _firestore
          .collection(AppConstants.collectionFarmers)
          .doc(farmer.farmerId)
          .set(farmer.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<List<FarmerModel>> fetchFarmers() async {
    try {
      final snap = await _firestore.collection(AppConstants.collectionFarmers).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => FarmerModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Markets Collection (SRS Table 1.8.5)
  static Future<void> saveMarket(MarketModel market) async {
    try {
      await _firestore
          .collection(AppConstants.collectionMarkets)
          .doc(market.marketId)
          .set(market.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<List<MarketModel>> fetchMarkets() async {
    try {
      final snap = await _firestore.collection(AppConstants.collectionMarkets).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((doc) => MarketModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ===============================================================
  // Real-Time Reactive Streams (Live Firestore Updates)
  // ===============================================================

  /// Real-time stream of all platform users
  static Stream<List<UserModel>> usersStream() {
    return _firestore.collection(AppConstants.collectionUsers).snapshots().map(
          (snap) => snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList(),
        );
  }

  /// Real-time stream of all active catalog products
  static Stream<List<ProductModel>> productsStream() {
    return _firestore.collection(AppConstants.collectionProducts).snapshots().map(
          (snap) => snap.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList(),
        );
  }

  /// Real-time stream of orders
  static Stream<List<OrderModel>> ordersStream() {
    return _firestore.collection(AppConstants.collectionOrders).snapshots().map(
          (snap) => snap.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList(),
        );
  }

  /// Real-time stream of inquiries & support tickets
  static Stream<List<SupportQueryModel>> queriesStream() {
    return _firestore
        .collection(collectionSupportQueries)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => SupportQueryModel.fromMap(doc.data())).toList());
  }

  /// Real-time stream of verified customer reviews
  static Stream<List<CustomerReviewModel>> reviewsStream() {
    return _firestore
        .collection(collectionCustomerReviews)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => CustomerReviewModel.fromMap(doc.data())).toList());
  }

  // ===============================================================
  // Support Inquiries & Customer Reviews Operations
  // ===============================================================

  static Future<void> saveSupportQuery(SupportQueryModel query) async {
    try {
      await _firestore
          .collection(collectionSupportQueries)
          .doc(query.id)
          .set(query.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> deleteSupportQuery(String queryId) async {
    try {
      await _firestore.collection(collectionSupportQueries).doc(queryId).delete();
    } catch (_) {}
  }

  static Future<List<SupportQueryModel>> fetchSupportQueries() async {
    try {
      final snap = await _firestore.collection(collectionSupportQueries).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => SupportQueryModel.fromMap(doc.data())).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveCustomerReview(CustomerReviewModel review) async {
    try {
      await _firestore
          .collection(collectionCustomerReviews)
          .doc(review.id)
          .set(review.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<void> deleteCustomerReview(String reviewId) async {
    try {
      await _firestore.collection(collectionCustomerReviews).doc(reviewId).delete();
    } catch (_) {}
  }

  static Future<List<CustomerReviewModel>> fetchCustomerReviews() async {
    try {
      final snap = await _firestore.collection(collectionCustomerReviews).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CustomerReviewModel.fromMap(doc.data())).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Initial Seed of SRS Collections into Cloud Firestore
  static Future<void> seedAllCollectionsToFirestore() async {
    try {
      // 1. Markets
      for (final market in seedMarkets) {
        await saveMarket(market);
      }
      // 2. Farmers
      for (final farmer in seedFarmers) {
        await saveFarmer(farmer);
      }
      // 3. Products
      final prodSnap = await _firestore.collection(AppConstants.collectionProducts).limit(1).get();
      if (prodSnap.docs.isEmpty) {
        for (final product in seedProducts) {
          await saveProduct(product);
        }
      }
      // 4. Categories
      final catSnap = await _firestore.collection('categories').limit(1).get();
      if (catSnap.docs.isEmpty) {
        for (final cat in AppConstants.categories) {
          final docId = cat.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
          await _firestore.collection('categories').doc(docId).set({
            'name': cat,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      // 5. Orders
      final orderSnap = await _firestore.collection(AppConstants.collectionOrders).limit(1).get();
      if (orderSnap.docs.isEmpty) {
        for (final order in seedOrders) {
          await saveOrder(order);
        }
      }
      // 6. Users
      final userSnap = await _firestore.collection(AppConstants.collectionUsers).limit(1).get();
      if (userSnap.docs.isEmpty) {
        for (final user in seedUsers) {
          await saveUserRecord(user);
        }
      }
    } catch (_) {}
  }
}
