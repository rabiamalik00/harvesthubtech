import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/support_query_model.dart';
import 'firebase_service.dart';

/// HarvestHub Support & Review Service
/// Manages Farmer queries, Customer support requests, and buyer reviews with
/// real-time Cloud Firestore synchronization and offline persistence.
class SupportService {
  static const String _keyQueries = 'harvesthub_support_queries';
  static const String _keyReviews = 'harvesthub_customer_reviews';

  static List<SupportQueryModel> _queries = [];
  static List<CustomerReviewModel> _reviews = [];
  static bool _initialized = false;

  /// ValueNotifier to trigger reactive UI updates across screens when Firestore syncs
  static final ValueNotifier<int> syncRevision = ValueNotifier<int>(0);

  static StreamSubscription<List<SupportQueryModel>>? _queriesSub;
  static StreamSubscription<List<CustomerReviewModel>>? _reviewsSub;

  static List<SupportQueryModel> get queries {
    if (!_initialized) _loadInitialSeed();
    return List.unmodifiable(_queries);
  }

  static List<CustomerReviewModel> get reviews {
    if (!_initialized) _loadInitialSeed();
    return List.unmodifiable(_reviews);
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawQueries = prefs.getString(_keyQueries);
    final rawReviews = prefs.getString(_keyReviews);

    if (rawQueries != null) {
      try {
        final List decoded = jsonDecode(rawQueries);
        _queries = decoded.map((m) => SupportQueryModel.fromMap(m)).toList();
      } catch (_) {
        _queries = _getSeedQueries();
      }
    } else {
      _queries = _getSeedQueries();
      await _persistQueries();
    }

    if (rawReviews != null) {
      try {
        final List decoded = jsonDecode(rawReviews);
        _reviews = decoded.map((m) => CustomerReviewModel.fromMap(m)).toList();
      } catch (_) {
        _reviews = _getSeedReviews();
      }
    } else {
      _reviews = _getSeedReviews();
      await _persistReviews();
    }

    _initialized = true;

    // Asynchronously bind real-time Firestore synchronization
    _attachFirestoreStreams();
  }

  static void _loadInitialSeed() {
    _queries = _getSeedQueries();
    _reviews = _getSeedReviews();
    _initialized = true;
  }

  static void _attachFirestoreStreams() {
    // 1. Real-time Support Queries stream
    _queriesSub?.cancel();
    _queriesSub = FirebaseService.queriesStream().listen(
      (remoteQueries) {
        if (remoteQueries.isNotEmpty) {
          _queries = remoteQueries;
          _persistQueries();
          syncRevision.value++;
        } else {
          // If Firestore is empty, seed it with initial English records
          for (final q in _getSeedQueries()) {
            FirebaseService.saveSupportQuery(q);
          }
        }
      },
      onError: (_) {
        // Fallback to offline cached records
      },
    );

    // 2. Real-time Customer Reviews stream
    _reviewsSub?.cancel();
    _reviewsSub = FirebaseService.reviewsStream().listen(
      (remoteReviews) {
        if (remoteReviews.isNotEmpty) {
          _reviews = remoteReviews;
          _persistReviews();
          syncRevision.value++;
        } else {
          // If Firestore is empty, seed it with initial English reviews
          for (final r in _getSeedReviews()) {
            FirebaseService.saveCustomerReview(r);
          }
        }
      },
      onError: (_) {
        // Fallback to offline cached records
      },
    );
  }

  static Future<void> addQuery(SupportQueryModel query) async {
    _queries.insert(0, query);
    await _persistQueries();
    syncRevision.value++;
    await FirebaseService.saveSupportQuery(query);
  }

  static Future<void> updateQueryStatus(
    String queryId,
    String newStatus, {
    String? adminReply,
  }) async {
    final idx = _queries.indexWhere((q) => q.id == queryId);
    if (idx != -1) {
      final old = _queries[idx];
      final updated = SupportQueryModel(
        id: old.id,
        userId: old.userId,
        userName: old.userName,
        userEmail: old.userEmail,
        userRole: old.userRole,
        subject: old.subject,
        message: old.message,
        category: old.category,
        status: newStatus,
        createdAt: old.createdAt,
        adminReply: adminReply ?? old.adminReply,
      );
      _queries[idx] = updated;
      await _persistQueries();
      syncRevision.value++;
      await FirebaseService.saveSupportQuery(updated);
    }
  }

  static Future<void> addReview(CustomerReviewModel review) async {
    _reviews.insert(0, review);
    await _persistReviews();
    syncRevision.value++;
    await FirebaseService.saveCustomerReview(review);
  }

  static Future<void> deleteQuery(String id) async {
    _queries.removeWhere((q) => q.id == id);
    await _persistQueries();
    syncRevision.value++;
    await FirebaseService.deleteSupportQuery(id);
  }

  static Future<void> deleteReview(String id) async {
    _reviews.removeWhere((r) => r.id == id);
    await _persistReviews();
    syncRevision.value++;
    await FirebaseService.deleteCustomerReview(id);
  }

  static Future<void> _persistQueries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _queries.map((q) => q.toMap()).toList();
      await prefs.setString(_keyQueries, jsonEncode(list));
    } catch (_) {}
  }

  static Future<void> _persistReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _reviews.map((r) => r.toMap()).toList();
      await prefs.setString(_keyReviews, jsonEncode(list));
    } catch (_) {}
  }

  static List<SupportQueryModel> _getSeedQueries() {
    return [
      SupportQueryModel(
        id: 'QRY-101',
        userId: 'farmer_demo_1',
        userName: 'Chaudhry Bashir Ahmad',
        userEmail: 'bashir.farmer@harvesthub.pk',
        userRole: 'Farmer',
        subject: 'Morning produce drop-off schedule extension',
        category: 'Pickup & Logistics',
        message:
            'Requesting early morning drop-off allocation at 06:00 AM at the Faisalabad Model Mandi collection hub to protect delicate leafy greens and vine-ripe tomatoes from summer midday heat.',
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
      SupportQueryModel(
        id: 'QRY-102',
        userId: 'farmer_demo_2',
        userName: 'Malik Zafar Iqbal',
        userEmail: 'zafar.citrus@harvesthub.pk',
        userRole: 'Farmer',
        subject: 'Kinnow export-grade batch payout release',
        category: 'Payout & Settlement',
        message:
            'Batch #KW-89 Sargodha citrus lot payment clearance confirmation requested. The buyer inspected and accepted the fruit consignment yesterday. When will escrow funds disburse?',
        status: 'In Review',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SupportQueryModel(
        id: 'QRY-103',
        userId: 'customer_demo_1',
        userName: 'Sara Ahmed',
        userEmail: 'sara.buyer@gmail.com',
        userRole: 'Customer',
        subject: 'Organic strawberry cold-chain guarantee',
        category: 'Product Quality',
        message:
            'Regarding tomorrow scheduled strawberry pickup at the Faisalabad Mandi hub: Will the berries be stored in refrigerated insulated containers? Can we perform a quality inspection at pickup?',
        status: 'In Review',
        createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      ),
      SupportQueryModel(
        id: 'QRY-104',
        userId: 'customer_demo_2',
        userName: 'Tariq Mehmood',
        userEmail: 'tariq.buyer@gmail.com',
        userRole: 'Customer',
        subject: 'Order #ORD-1002 pickup slot rescheduling',
        category: 'Pickup & Logistics',
        message:
            'Due to an unexpected meeting, I will be delayed. Kindly reschedule my pickup window from 04:00 PM to 06:30 PM today. Please notify the mandi customer counter.',
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      SupportQueryModel(
        id: 'QRY-105',
        userId: 'farmer_demo_3',
        userName: 'Ghulam Rasool',
        userEmail: 'ghulam.wheat@harvesthub.pk',
        userRole: 'Farmer',
        subject: 'Wheat foliar yellow rust broadcast advisory',
        category: 'Crop Advisory',
        message:
            'Yellow rust foliar symptoms have been spotted in Jhang and Faisalabad district wheat belts after recent rains. Could the platform issue a broadcast alert recommending protective fungicide treatment?',
        status: 'Resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        adminReply:
            'Agricultural advisory alert published via Dr. Imran Siddiqui AI Advisory module and push broadcast sent to regional wheat growers.',
      ),
    ];
  }

  static List<CustomerReviewModel> _getSeedReviews() {
    return [
      CustomerReviewModel(
        id: 'REV-201',
        customerName: 'Zainab Bibi',
        customerEmail: 'zainab.b@gmail.com',
        targetFarmerOrMandi: 'Bashir Green Organic Farms • Faisalabad Mandi',
        rating: 5.0,
        comment:
            'The organic tomatoes and farm-fresh spinach were remarkably crisp and fragrant! Sourced directly without middlemen markups. First time buying produce at such honest prices.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        verifiedPurchase: true,
      ),
      CustomerReviewModel(
        id: 'REV-202',
        customerName: 'Dr. Kamran Ali',
        customerEmail: 'kamran.ali@hospital.pk',
        targetFarmerOrMandi: 'Punjab Pure Dairy & Grains • Lahore Mandi',
        rating: 5.0,
        comment:
            'Genuine pure buffalo milk and churned deshi butter! Tested with purity strips—zero adulterants and optimum fat content. HarvestHub direct farmer model is outstanding.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        verifiedPurchase: true,
      ),
      CustomerReviewModel(
        id: 'REV-203',
        customerName: 'Hamza Sheikh',
        customerEmail: 'hamza.sheikh@tech.pk',
        targetFarmerOrMandi: 'Sargodha Citrus Orchards • Model Mandi',
        rating: 4.5,
        comment:
            'Kinnow oranges were sweet and juicy. Well packaged in ventilated cartons. Pickup counter had zero line wait. Exemplary 10/10 service for local agriculture.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        verifiedPurchase: true,
      ),
      CustomerReviewModel(
        id: 'REV-204',
        customerName: 'Mrs. Farooq',
        customerEmail: 'farooq.family@gmail.com',
        targetFarmerOrMandi: 'Multan Mango & Guava Belts',
        rating: 5.0,
        comment:
            'Delicious farm guavas, picked at peak ripeness. The order tracking was accurate and the mandi pickup desk had everything boxed and ready on time. Highly recommended!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        verifiedPurchase: true,
      ),
    ];
  }
}
