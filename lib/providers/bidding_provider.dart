import 'package:flutter/material.dart';
import '../models/bid_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class BiddingProvider extends ChangeNotifier {
  List<BidModel> _bids = [];

  List<BidModel> get bids => _bids;

  BiddingProvider() {
    loadBids();
  }

  void loadBids() {
    _bids = StorageService.loadBids();
    notifyListeners();
  }

  List<BidModel> getBuyerBids(String buyerId) {
    return _bids.where((b) => b.buyerId == buyerId).toList();
  }

  List<BidModel> getFarmerBids(String farmerId) {
    return _bids.where((b) => b.farmerId == farmerId).toList();
  }

  BidModel createBid({
    required ProductModel product,
    required UserModel buyer,
    required int requestedQtyKg,
    required double offeredPricePerKg,
    required String message,
  }) {
    final newBid = BidModel(
      id: 'BID-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      productId: product.id,
      productName: product.name,
      buyerId: buyer.id,
      buyerName: buyer.name,
      farmerId: product.farmerId,
      farmerName: product.farmerName ?? '',
      requestedQtyKg: requestedQtyKg,
      originalPricePerKg: product.pricePerKg,
      offeredPricePerKg: offeredPricePerKg,
      status: BidStatus.pending,
      message: message,
      createdAt: DateTime.now(),
    );

    _bids.insert(0, newBid);
    StorageService.saveBids(_bids);
    notifyListeners();
    return newBid;
  }

  void makeCounterOffer(String bidId, double counterPrice) {
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        counterPricePerKg: counterPrice,
        status: BidStatus.counterOffered,
      );
      StorageService.saveBids(_bids);
      notifyListeners();
    }
  }

  void acceptBid(String bidId) {
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        status: BidStatus.accepted,
      );
      StorageService.saveBids(_bids);
      notifyListeners();
    }
  }

  void declineBid(String bidId) {
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        status: BidStatus.declined,
      );
      StorageService.saveBids(_bids);
      notifyListeners();
    }
  }
}
