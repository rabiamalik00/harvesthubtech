class FarmerModel {
  final String farmerId;
  final String userId;
  final String marketId;
  final String businessName;
  final String description;
  final double rating;
  final List<String> followers;

  FarmerModel({
    required this.farmerId,
    required this.userId,
    required this.marketId,
    required this.businessName,
    required this.description,
    this.rating = 4.8,
    required this.followers,
  });

  FarmerModel copyWith({
    String? farmerId,
    String? userId,
    String? marketId,
    String? businessName,
    String? description,
    double? rating,
    List<String>? followers,
  }) {
    return FarmerModel(
      farmerId: farmerId ?? this.farmerId,
      userId: userId ?? this.userId,
      marketId: marketId ?? this.marketId,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      followers: followers ?? this.followers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmer_id': farmerId,
      'user_id': userId,
      'market_id': marketId,
      'business_name': businessName,
      'description': description,
      'rating': rating,
      'followers': followers,
    };
  }

  factory FarmerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmerModel(
      farmerId: map['farmer_id'] ?? documentId,
      userId: map['user_id'] ?? '',
      marketId: map['market_id'] ?? '',
      businessName: map['business_name'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.8,
      followers: List<String>.from(map['followers'] ?? []),
    );
  }
}
