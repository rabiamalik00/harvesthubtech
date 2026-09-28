enum DisputeStatus {
  open,
  underReview,
  resolved,
  refunded
}

class DisputeModel {
  final String id;
  final String orderId;
  final String raisedByUserId;
  final String raisedByUserName;
  final String partyInvolvedName; // e.g. Farmer name
  final String issueType; // 'Damaged Goods', 'Delayed Delivery', 'Quality Mismatch', 'Packaging Issue'
  final String description;
  final DisputeStatus status;
  final String? resolutionNote;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.raisedByUserId,
    required this.raisedByUserName,
    required this.partyInvolvedName,
    required this.issueType,
    required this.description,
    this.status = DisputeStatus.open,
    this.resolutionNote,
    required this.createdAt,
  });

  DisputeModel copyWith({
    DisputeStatus? status,
    String? resolutionNote,
  }) {
    return DisputeModel(
      id: id,
      orderId: orderId,
      raisedByUserId: raisedByUserId,
      raisedByUserName: raisedByUserName,
      partyInvolvedName: partyInvolvedName,
      issueType: issueType,
      description: description,
      status: status ?? this.status,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'raisedByUserId': raisedByUserId,
      'raisedByUserName': raisedByUserName,
      'partyInvolvedName': partyInvolvedName,
      'issueType': issueType,
      'description': description,
      'status': status.name,
      'resolutionNote': resolutionNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DisputeModel.fromMap(Map<String, dynamic> map) {
    return DisputeModel(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      raisedByUserId: map['raisedByUserId'] ?? '',
      raisedByUserName: map['raisedByUserName'] ?? '',
      partyInvolvedName: map['partyInvolvedName'] ?? '',
      issueType: map['issueType'] ?? 'Quality Issue',
      description: map['description'] ?? '',
      status: DisputeStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => DisputeStatus.open,
      ),
      resolutionNote: map['resolutionNote'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
