// HarvestHub Platform Support Query & Customer Review Models
// Represents authentic farmer questions, customer inquiries, and rating feedback.
library;
class SupportQueryModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole; // 'Farmer' | 'Customer'
  final String subject;
  final String message;
  final String category;
  String status; // 'Pending' | 'In Review' | 'Resolved'
  final DateTime createdAt;
  String? adminReply;

  SupportQueryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.subject,
    required this.message,
    required this.category,
    this.status = 'Pending',
    required this.createdAt,
    this.adminReply,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userRole': userRole,
        'subject': subject,
        'message': message,
        'category': category,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'adminReply': adminReply,
      };

  factory SupportQueryModel.fromMap(Map<String, dynamic> map) => SupportQueryModel(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'HarvestHub Member',
        userEmail: map['userEmail'] ?? '',
        userRole: map['userRole'] ?? 'Customer',
        subject: map['subject'] ?? 'General Inquiry',
        message: map['message'] ?? '',
        category: map['category'] ?? 'General',
        status: map['status'] ?? 'Pending',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        adminReply: map['adminReply'],
      );
}

class CustomerReviewModel {
  final String id;
  final String customerName;
  final String customerEmail;
  final String targetFarmerOrMandi;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool verifiedPurchase;

  CustomerReviewModel({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.targetFarmerOrMandi,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.verifiedPurchase = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'targetFarmerOrMandi': targetFarmerOrMandi,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'verifiedPurchase': verifiedPurchase,
      };

  factory CustomerReviewModel.fromMap(Map<String, dynamic> map) => CustomerReviewModel(
        id: map['id'] ?? '',
        customerName: map['customerName'] ?? 'Verified Customer',
        customerEmail: map['customerEmail'] ?? '',
        targetFarmerOrMandi: map['targetFarmerOrMandi'] ?? 'Local Mandi Hub',
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        comment: map['comment'] ?? '',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        verifiedPurchase: map['verifiedPurchase'] ?? true,
      );
}
