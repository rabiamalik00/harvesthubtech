import 'package:cloud_firestore/cloud_firestore.dart';

class MarketModel {
  final String marketId;
  final String marketName;
  final String address;
  final GeoPoint? gpsCoordinates;
  final String operatingHours;
  final bool activeStatus;

  MarketModel({
    required this.marketId,
    required this.marketName,
    required this.address,
    this.gpsCoordinates,
    required this.operatingHours,
    this.activeStatus = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'market_id': marketId,
      'market_name': marketName,
      'address': address,
      'gps_coordinates': gpsCoordinates ?? const GeoPoint(31.5204, 74.3587),
      'operating_hours': operatingHours,
      'active_status': activeStatus,
    };
  }

  factory MarketModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MarketModel(
      marketId: map['market_id'] ?? documentId,
      marketName: map['market_name'] ?? '',
      address: map['address'] ?? '',
      gpsCoordinates: map['gps_coordinates'] is GeoPoint
          ? map['gps_coordinates'] as GeoPoint
          : const GeoPoint(31.5204, 74.3587),
      operatingHours: map['operating_hours'] ?? '08:00 AM - 06:00 PM',
      activeStatus: map['active_status'] ?? true,
    );
  }
}
