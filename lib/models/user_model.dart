import 'package:cloud_firestore/cloud_firestore.dart';

// Sentinel used in copyWith to distinguish "not provided" from explicit null
const _sentinel = Object();

enum UserRole { farmer, buyer, admin, customer }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.buyer:
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool isCustomerOrBuyer() => this == UserRole.buyer || this == UserRole.customer;
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Customer' | 'Farmer' | 'Admin'
  final DateTime createdAt;
  final String address;
  final String? farmName;
  final String? marketName;
  final String? profilePhoto; // base64 data URL or network URL

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.address = '',
    this.farmName,
    this.marketName,
    this.profilePhoto,
  });

  // Backward compatibility getters
  String get id => uid;
  String? get farmLocation => address.isNotEmpty ? address : marketName;
  String? get district => null;
  String? get tehsil => null;
  bool get isVerified => true;
  bool get isBlocked => false;
  bool get isEmailVerified => true;
  String get authProvider => 'email';

  bool get isCustomer => role == 'Customer' || role == 'buyer';
  bool get isFarmer => role == 'Farmer' || role == 'farmer';
  bool get isAdmin => role == 'Admin' || role == 'admin';

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? address,
    String? farmName,
    String? marketName,
    Object? profilePhoto = _sentinel,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      farmName: farmName ?? this.farmName,
      marketName: marketName ?? this.marketName,
      profilePhoto: profilePhoto == _sentinel ? this.profilePhoto : profilePhoto as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'address': address,
      if (farmName != null) 'farm_name': farmName,
      if (marketName != null) 'market_name': marketName,
      // Store only network URLs in Firestore; large base64 stays local
      if (profilePhoto != null && !profilePhoto!.startsWith('data:')) 'profile_photo': profilePhoto,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  factory UserModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    DateTime parsedDate = DateTime.now();
    if (map['created_at'] != null) {
      if (map['created_at'] is Timestamp) {
        parsedDate = (map['created_at'] as Timestamp).toDate();
      } else if (map['created_at'] is String) {
        parsedDate = DateTime.tryParse(map['created_at']) ?? DateTime.now();
      }
    }

    return UserModel(
      uid: map['uid'] ?? documentId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'Customer',
      createdAt: parsedDate,
      address: map['address'] ?? '',
      farmName: map['farm_name'] ?? map['farmName'],
      marketName: map['market_name'] ?? map['marketName'],
      profilePhoto: map['profile_photo'] ?? map['profilePhoto'],
    );
  }
}
