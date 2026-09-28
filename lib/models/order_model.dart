import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  placed,
  processing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItemModel {
  final String productId;
  final String itemName;
  final int quantity;
  final double pricePerUnit;
  final String unit;

  OrderItemModel({
    required this.productId,
    required this.itemName,
    required this.quantity,
    required this.pricePerUnit,
    this.unit = 'kg',
  });

  // Backward compatibility getters
  int get quantityKg => quantity;
  double get unitPrice => pricePerUnit;
  double get itemTotal => quantity * pricePerUnit;
  String get productName => itemName;
  String get farmerName => 'Bashir Green Organic Farms';

  /// Clean item name removing legacy lit/litre tags if any
  String get cleanName => itemName
      .replaceAll('(1 Litre)', '')
      .replaceAll('(1L)', '')
      .replaceAll('(1 kg)', '')
      .trim();

  /// E.g. "2 kg Pure Farm Milk"
  String get displayTitle => '$quantity $unit $cleanName';

  double get totalPrice => quantity * pricePerUnit;

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'item_name': cleanName,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'unit': unit,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['product_id'] ?? map['productId'] ?? '',
      itemName: (map['item_name'] ?? map['productName'] ?? '')
          .toString()
          .replaceAll('(1 Litre)', '')
          .replaceAll('(1 kg)', '')
          .trim(),
      quantity: (map['quantity'] is num)
          ? (map['quantity'] as num).toInt()
          : ((map['quantityKg'] is num) ? (map['quantityKg'] as num).toInt() : 1),
      pricePerUnit: (map['price_per_unit'] is num)
          ? (map['price_per_unit'] as num).toDouble()
          : ((map['unitPrice'] is num) ? (map['unitPrice'] as num).toDouble() : 0.0),
      unit: map['unit']?.toString() ?? 'kg',
    );
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final String farmerId;
  final List<OrderItemModel> items;
  final String pickupSlotTime;
  final String status; // 'Pending' | 'Confirmed' | 'Ready for Pickup' | 'Completed' | 'Cancelled'
  final double totalPrice;
  final double platformFee;
  final DateTime createdAt;
  final String? customerName;
  final String? farmerBusinessName;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.farmerId,
    required this.items,
    required this.pickupSlotTime,
    required this.status,
    required this.totalPrice,
    this.platformFee = 20.0,
    required this.createdAt,
    this.customerName,
    this.farmerBusinessName,
    String? deliveryAddress,
  }) : _deliveryAddress = deliveryAddress ?? '';

  final String _deliveryAddress;

  // Backward compatibility getters
  double get itemsSubtotal => items.fold(0.0, (acc, i) => acc + i.totalPrice);
  String get id => orderId;
  double get subtotal => totalPrice;
  double get discount => 0.0;
  double get platformCommission => totalPrice * 0.03;
  double get effectiveTotal => totalPrice;

  String get buyerName => customerName ?? 'Tariq Mehmood';
  String get buyerPhone => '+92 300 1112233';
  String get deliveryAddress => _deliveryAddress.isNotEmpty ? _deliveryAddress : pickupSlotTime;
  String get pickupSlot => pickupSlotTime;
  String get district => 'Faisalabad';
  bool get isPaid => true;
  String get paymentMethodDisplay => 'Cash on Pickup';

  OrderStatus get orderStatus {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
      case 'processing':
        return OrderStatus.processing;
      case 'ready for pickup':
      case 'readyforpickup':
        return OrderStatus.readyForPickup;
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'completed':
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? farmerId,
    List<OrderItemModel>? items,
    String? pickupSlotTime,
    String? status,
    double? totalPrice,
    double? platformFee,
    DateTime? createdAt,
    String? customerName,
    String? farmerBusinessName,
    String? deliveryAddress,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      farmerId: farmerId ?? this.farmerId,
      items: items ?? this.items,
      pickupSlotTime: pickupSlotTime ?? this.pickupSlotTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      platformFee: platformFee ?? this.platformFee,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      farmerBusinessName: farmerBusinessName ?? this.farmerBusinessName,
      deliveryAddress: deliveryAddress ?? _deliveryAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'farmer_id': farmerId,
      'items': items.map((i) => i.toMap()).toList(),
      'pickup_slot_time': pickupSlotTime,
      'status': status,
      'total_price': totalPrice,
      'platform_fee': platformFee,
      'created_at': createdAt.toIso8601String(),
      if (customerName != null) 'customer_name': customerName,
      if (farmerBusinessName != null) 'farmer_business_name': farmerBusinessName,
      'delivery_address': _deliveryAddress,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel.fromMap(json);

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    DateTime parsedDate = DateTime.now();
    if (map['created_at'] != null) {
      if (map['created_at'] is Timestamp) {
        parsedDate = (map['created_at'] as Timestamp).toDate();
      } else if (map['created_at'] is String) {
        parsedDate = DateTime.tryParse(map['created_at']) ?? DateTime.now();
      }
    }

    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((i) => OrderItemModel.fromMap(Map<String, dynamic>.from(i)))
        .toList();

    return OrderModel(
      orderId: map['order_id'] ?? map['id'] ?? documentId ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      farmerId: map['farmer_id'] ?? map['farmerId'] ?? '',
      items: itemsList,
      pickupSlotTime: map['pickup_slot_time'] ?? map['pickupSlotTime'] ?? '10:00 AM - 12:00 PM',
      status: map['status'] ?? 'Pending',
      totalPrice: (map['total_price'] is num)
          ? (map['total_price'] as num).toDouble()
          : ((map['effectiveTotal'] is num) ? (map['effectiveTotal'] as num).toDouble() : 0.0),
      platformFee: (map['platform_fee'] is num)
          ? (map['platform_fee'] as num).toDouble()
          : 20.0,
      createdAt: parsedDate,
      customerName: map['customer_name'] ?? map['customerName'],
      farmerBusinessName: map['farmer_business_name'] ?? map['farmerBusinessName'],
      deliveryAddress: map['delivery_address'] ?? map['deliveryAddress'] ?? '',
    );
  }
}
