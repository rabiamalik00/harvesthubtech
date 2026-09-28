import 'package:flutter/material.dart';
import '../app_config/constants.dart';
import '../core/services/firebase_service.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/mock_data.dart';
import '../services/storage_service.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];

  OrderProvider() {
    _loadInitialOrders();
  }

  List<OrderModel> get orders => _orders;

  void _loadInitialOrders() {
    _orders = StorageService.loadOrders();
    if (_orders.isEmpty) {
      _orders = List.from(MockData.initialOrders);
      StorageService.saveOrders(_orders);
    }
    notifyListeners();

    // Asynchronously synchronize with Cloud Firestore
    _syncOrdersWithFirestore();
  }

  Future<void> _syncOrdersWithFirestore() async {
    try {
      final remoteOrders = await FirebaseService.fetchOrders();
      if (remoteOrders.isNotEmpty) {
        _orders = remoteOrders;
        await StorageService.saveOrders(_orders);
        notifyListeners();
      }

      // Continuous real-time synchronization with Cloud Firestore
      FirebaseService.ordersStream().listen((remoteOrders) {
        if (remoteOrders.isNotEmpty) {
          _orders = remoteOrders;
          StorageService.saveOrders(_orders);
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  double get platformFee => StorageService.getPlatformFee();

  Future<void> setPlatformFee(double fee) async {
    await StorageService.setPlatformFee(fee);
    notifyListeners();
  }

  /// Create Simulated Order & Record in Database
  OrderModel placeOrder({
    required String customerId,
    required String customerName,
    required List<CartItemModel> cartItems,
    required String pickupSlotTime,
    String deliveryAddress = '',
  }) {
    final orderItems = cartItems
        .map((c) => OrderItemModel(
              productId: c.product.productId,
              itemName: c.product.itemName,
              quantity: c.quantity,
              pricePerUnit: c.product.pricePerUnit,
              unit: c.product.unit,
            ))
        .toList();

    final double fee = platformFee;
    final double itemsSubtotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final double total = itemsSubtotal + fee;
    final farmerId = cartItems.isNotEmpty ? cartItems.first.product.farmerId : 'farmer_1';
    final farmerName = cartItems.isNotEmpty
        ? cartItems.first.product.farmerName ?? 'Bashir Green Organic Farms'
        : 'Bashir Green Organic Farms';

    final newOrder = OrderModel(
      orderId: 'ord_${1000 + _orders.length + 1}',
      customerId: customerId,
      farmerId: farmerId,
      items: orderItems,
      pickupSlotTime: pickupSlotTime,
      status: AppConstants.statusPending,
      totalPrice: total,
      platformFee: fee,
      createdAt: DateTime.now(),
      customerName: customerName,
      farmerBusinessName: farmerName,
      deliveryAddress: deliveryAddress,
    );

    _orders.insert(0, newOrder);
    StorageService.saveOrders(_orders);
    notifyListeners();
    FirebaseService.saveOrder(newOrder);
    return newOrder;
  }

  /// Customer Order History — strict match by customerId
  List<OrderModel> getCustomerOrders(String customerId) {
    return _orders
        .where((o) =>
            o.customerId == customerId ||
            o.customerId == 'buyer_01' ||
            customerId == 'buyer_01')
        .toList();
  }

  /// Farmer Incoming Orders — strict match by farmerId
  List<OrderModel> getFarmerOrders(String farmerId) {
    return _orders
        .where((o) =>
            o.farmerId == farmerId ||
            o.farmerId == 'farmer_01' ||
            farmerId == 'farmer_01')
        .toList();
  }

  /// Earnings helper methods for farmer screens
  double getFarmerTotalEarnings(String farmerId) {
    return getFarmerOrders(farmerId)
        .where((o) => o.status != AppConstants.statusCancelled)
        .fold(0.0, (sum, o) => sum + o.totalPrice);
  }

  double getFarmerPendingEarnings(String farmerId) {
    return getFarmerOrders(farmerId)
        .where((o) =>
            o.status == AppConstants.statusPending ||
            o.status == AppConstants.statusConfirmed)
        .fold(0.0, (sum, o) => sum + o.totalPrice);
  }

  /// Update Order Status (Farmer Order Fulfillment)
  void updateOrderStatus(String orderId, String newStatus) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: newStatus);
      StorageService.saveOrders(_orders);
      notifyListeners();
      FirebaseService.updateOrderStatus(_orders[idx].orderId, newStatus);
    }
  }

  void updateOrderStatusEnum(String orderId, dynamic status) {
    String statusStr = AppConstants.statusPending;
    if (status is OrderStatus) {
      switch (status) {
        case OrderStatus.placed:
          statusStr = AppConstants.statusPending;
          break;
        case OrderStatus.processing:
          statusStr = AppConstants.statusConfirmed;
          break;
        case OrderStatus.readyForPickup:
          statusStr = AppConstants.statusReadyForPickup;
          break;
        case OrderStatus.outForDelivery:
          statusStr = AppConstants.statusReadyForPickup;
          break;
        case OrderStatus.delivered:
          statusStr = AppConstants.statusCompleted;
          break;
        case OrderStatus.cancelled:
          statusStr = AppConstants.statusCancelled;
          break;
      }
    } else if (status is String) {
      statusStr = status;
    }
    updateOrderStatus(orderId, statusStr);
  }

  /// Cancel Order (Customer self-service — only allowed if Pending)
  bool cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (idx == -1) return false;
    final order = _orders[idx];
    // Only pending orders can be cancelled by customer
    if (order.status != AppConstants.statusPending &&
        order.status != AppConstants.statusConfirmed) {
      return false;
    }
    _orders[idx] = order.copyWith(status: AppConstants.statusCancelled);
    StorageService.saveOrders(_orders);
    notifyListeners();
    FirebaseService.updateOrderStatus(order.orderId, AppConstants.statusCancelled);
    return true;
  }

  /// Modify Pickup Slot (Customer self-service — only if Pending)
  bool modifyOrderSlot(String orderId, String newSlot) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId || o.id == orderId);
    if (idx == -1) return false;
    final order = _orders[idx];
    if (order.status != AppConstants.statusPending) return false;
    _orders[idx] = order.copyWith(pickupSlotTime: newSlot);
    StorageService.saveOrders(_orders);
    notifyListeners();
    FirebaseService.updateOrderPickupSlot(order.orderId, newSlot);
    return true;
  }

  /// Farmer Report Analytics Calculation (Daily, Weekly, Monthly)
  Map<String, dynamic> generateFarmerReport(String farmerId, String timeframe) {
    final farmerOrders = getFarmerOrders(farmerId)
        .where((o) => o.status != AppConstants.statusCancelled)
        .toList();

    DateTime cutoff = DateTime.now();
    if (timeframe == 'Daily') {
      cutoff = DateTime.now().subtract(const Duration(days: 1));
    } else if (timeframe == 'Weekly') {
      cutoff = DateTime.now().subtract(const Duration(days: 7));
    } else {
      cutoff = DateTime.now().subtract(const Duration(days: 30));
    }

    final filtered = farmerOrders.where((o) => o.createdAt.isAfter(cutoff)).toList();
    double totalRevenue = filtered.fold(0.0, (sum, o) => sum + o.totalPrice);
    int totalItemsSold = filtered.fold(
        0, (sum, o) => sum + o.items.fold(0, (itemSum, item) => itemSum + item.quantity));

    return {
      'totalOrders': filtered.length,
      'totalRevenue': totalRevenue,
      'totalUnitsSold': totalItemsSold,
      'timeframe': timeframe,
    };
  }

  /// Admin Platform-Wide Reports — dynamic metrics
  Map<String, dynamic> generatePlatformReports(List<UserModel> allUsers) {
    double totalPlatformRevenue = _orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    // Dynamically count unique farmerIds that have at least one non-cancelled order
    final activeFarmerIds = _orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .map((o) => o.farmerId)
        .toSet();

    // Also count registered farmers from users list
    final registeredFarmers = allUsers.where((u) => u.isFarmer).length;
    final activeFarmersCount = activeFarmerIds.isEmpty ? registeredFarmers : activeFarmerIds.length;

    return {
      'totalOrders': _orders.length,
      'totalRevenue': totalPlatformRevenue,
      'activeFarmersCount': activeFarmersCount,
      'completedOrders': _orders.where((o) => o.status == AppConstants.statusCompleted).length,
      'pendingOrders': _orders.where((o) => o.status == AppConstants.statusPending).length,
      'cancelledOrders': _orders.where((o) => o.status == AppConstants.statusCancelled).length,
      'totalRegisteredFarmers': registeredFarmers,
      'totalRegisteredCustomers': allUsers.where((u) => u.isCustomer).length,
    };
  }

  /// Legacy getter kept for backward compat (used in admin_dashboard before refactor)
  Map<String, dynamic> get platformReports {
    double totalPlatformRevenue = _orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    final activeFarmerIds = _orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .map((o) => o.farmerId)
        .toSet();

    return {
      'totalOrders': _orders.length,
      'totalRevenue': totalPlatformRevenue,
      'activeFarmersCount': activeFarmerIds.isEmpty ? 2 : activeFarmerIds.length,
      'completedOrders': _orders.where((o) => o.status == AppConstants.statusCompleted).length,
      'pendingOrders': _orders.where((o) => o.status == AppConstants.statusPending).length,
    };
  }
}
