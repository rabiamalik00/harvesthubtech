enum BidStatus {
  pending,
  counterOffered,
  accepted,
  declined
}

class BidModel {
  final String id;
  final String productId;
  final String productName;
  final String buyerId;
  final String buyerName;
  final String farmerId;
  final String farmerName;
  final int requestedQtyKg;
  final double originalPricePerKg;
  final double offeredPricePerKg;
  final double? counterPricePerKg;
  final BidStatus status;
  final String message;
  final DateTime createdAt;

  BidModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.farmerName,
    required this.requestedQtyKg,
    required this.originalPricePerKg,
    required this.offeredPricePerKg,
    this.counterPricePerKg,
    this.status = BidStatus.pending,
    this.message = '',
    required this.createdAt,
  });

  BidModel copyWith({
    double? counterPricePerKg,
    BidStatus? status,
    String? message,
  }) {
    return BidModel(
      id: id,
      productId: productId,
      productName: productName,
      buyerId: buyerId,
      buyerName: buyerName,
      farmerId: farmerId,
      farmerName: farmerName,
      requestedQtyKg: requestedQtyKg,
      originalPricePerKg: originalPricePerKg,
      offeredPricePerKg: offeredPricePerKg,
      counterPricePerKg: counterPricePerKg ?? this.counterPricePerKg,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'requestedQtyKg': requestedQtyKg,
      'originalPricePerKg': originalPricePerKg,
      'offeredPricePerKg': offeredPricePerKg,
      'counterPricePerKg': counterPricePerKg,
      'status': status.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      requestedQtyKg: (map['requestedQtyKg'] as num?)?.toInt() ?? 50,
      originalPricePerKg: (map['originalPricePerKg'] as num?)?.toDouble() ?? 0.0,
      offeredPricePerKg: (map['offeredPricePerKg'] as num?)?.toDouble() ?? 0.0,
      counterPricePerKg: (map['counterPricePerKg'] as num?)?.toDouble(),
      status: BidStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BidStatus.pending,
      ),
      message: map['message'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
