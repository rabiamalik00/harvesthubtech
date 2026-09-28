class ProductModel {
  final String productId;
  final String farmerId;
  final String itemName;
  final String category; // 'Fruits' | 'Vegetables' | 'Grains' | 'Dairy' | 'Herbs' | 'Organic'
  final double pricePerUnit;
  final int stockQty;
  final String imageUrl;
  final String? farmerName;
  final String? marketName;
  final DateTime? harvestDate;
  final String? description;
  final String? farmLocation;
  final String? iconCode;
  final String unit;
  final int? reviewsCount;

  ProductModel({
    String? productId,
    String? id,
    required this.farmerId,
    String? itemName,
    String? name,
    required this.category,
    double? pricePerUnit,
    double? pricePerKg,
    int? stockQty,
    int? stockKg,
    required this.imageUrl,
    this.farmerName,
    this.marketName,
    this.unit = 'kg',
    bool? isOrganic,
    this.harvestDate,
    this.description,
    this.farmLocation,
    String? district,
    this.iconCode,
    double? rating,
    this.reviewsCount,
  })  : productId = productId ?? id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
        itemName = itemName ?? name ?? 'Harvest Item',
        pricePerUnit = pricePerUnit ?? pricePerKg ?? 0.0,
        stockQty = stockQty ?? stockKg ?? 0;

  // Backward compatibility getters
  String get id => productId;
  String get name => itemName;
  double get pricePerKg => pricePerUnit;
  int get stockKg => stockQty;
  bool get isOrganic => category == 'Organic';
  double get rating => 4.8;
  String get district => 'Faisalabad';

  bool get inStock => stockQty > 0;

  ProductModel copyWith({
    String? productId,
    String? farmerId,
    String? itemName,
    String? category,
    double? pricePerUnit,
    int? stockQty,
    String? imageUrl,
    String? farmerName,
    String? marketName,
    DateTime? harvestDate,
    String? description,
    String? farmLocation,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      stockQty: stockQty ?? this.stockQty,
      imageUrl: imageUrl ?? this.imageUrl,
      farmerName: farmerName ?? this.farmerName,
      marketName: marketName ?? this.marketName,
      harvestDate: harvestDate ?? this.harvestDate,
      description: description ?? this.description,
      farmLocation: farmLocation ?? this.farmLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'farmer_id': farmerId,
      'item_name': itemName,
      'category': category,
      'price_per_unit': pricePerUnit,
      'unit': unit,
      'stock_qty': stockQty,
      'image_url': imageUrl,
      if (farmerName != null) 'farmer_name': farmerName,
      if (marketName != null) 'market_name': marketName,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return ProductModel(
      productId: map['product_id'] ?? map['id'] ?? documentId ?? '',
      farmerId: map['farmer_id'] ?? '',
      itemName: map['item_name'] ?? map['name'] ?? '',
      category: map['category'] ?? 'Vegetables',
      pricePerUnit: (map['price_per_unit'] is num)
          ? (map['price_per_unit'] as num).toDouble()
          : ((map['pricePerKg'] is num) ? (map['pricePerKg'] as num).toDouble() : 0.0),
      unit: map['unit']?.toString() ?? 'kg',
      stockQty: (map['stock_qty'] is num)
          ? (map['stock_qty'] as num).toInt()
          : ((map['stockKg'] is num) ? (map['stockKg'] as num).toInt() : 0),
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? 'https://images.unsplash.com/photo-1540420773420-3366772f4999',
      farmerName: map['farmer_name'] ?? map['farmerName'],
      marketName: map['market_name'] ?? map['marketName'],
    );
  }
}
