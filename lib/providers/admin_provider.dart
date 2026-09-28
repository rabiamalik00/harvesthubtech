import 'package:flutter/material.dart';
import '../models/dispute_model.dart';
import '../models/order_model.dart';
import '../services/storage_service.dart';

class AdminProvider extends ChangeNotifier {
  List<DisputeModel> _disputes = [];
  double _commissionRate = 3.0;
  String _systemAnnouncement = '🌾 Official Punjab Mandi Rates Active • 3% Escrow Protection Guaranteed';
  double _payoutsReleased = 485000.0;

  List<DisputeModel> get disputes => _disputes;
  double get commissionRate => _commissionRate;
  String get systemAnnouncement => _systemAnnouncement;
  double get payoutsReleased => _payoutsReleased;

  AdminProvider() {
    loadData();
  }

  void loadData() {
    _disputes = StorageService.loadDisputes();
    _commissionRate = StorageService.getCommissionRate();
    notifyListeners();
  }

  void updateCommissionRate(double newRate) {
    _commissionRate = newRate;
    StorageService.setCommissionRate(newRate);
    notifyListeners();
  }

  void updateSystemAnnouncement(String message) {
    _systemAnnouncement = message;
    notifyListeners();
  }

  void releaseFarmerPayout(double amount) {
    _payoutsReleased += amount;
    notifyListeners();
  }

  void resolveDispute(String disputeId, String resolutionNote, {bool isRefund = false}) {
    final index = _disputes.indexWhere((d) => d.id == disputeId);
    if (index != -1) {
      _disputes[index] = _disputes[index].copyWith(
        status: isRefund ? DisputeStatus.refunded : DisputeStatus.resolved,
        resolutionNote: resolutionNote,
      );
      StorageService.saveDisputes(_disputes);
      notifyListeners();
    }
  }

  void raiseDispute({
    required OrderModel order,
    required String issueType,
    required String description,
  }) {
    final farmerName = order.items.isNotEmpty ? order.items.first.farmerName : 'Farmer';
    final newDispute = DisputeModel(
      id: 'DSP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      orderId: order.id,
      raisedByUserId: order.customerId,
      raisedByUserName: order.buyerName,
      partyInvolvedName: farmerName,
      issueType: issueType,
      description: description,
      status: DisputeStatus.open,
      createdAt: DateTime.now(),
    );

    _disputes.insert(0, newDispute);
    StorageService.saveDisputes(_disputes);
    notifyListeners();
  }
}
