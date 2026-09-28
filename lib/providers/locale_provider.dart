import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/localization.dart';

class LocaleProvider extends ChangeNotifier {
  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;

  LocaleProvider() {
    _isUrdu = StorageService.getIsUrdu();
  }

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    StorageService.setIsUrdu(_isUrdu);
    notifyListeners();
  }

  void setUrdu(bool value) {
    if (_isUrdu != value) {
      _isUrdu = value;
      StorageService.setIsUrdu(_isUrdu);
      notifyListeners();
    }
  }

  String tr(String key) {
    return AppStrings.tr(key, _isUrdu);
  }
}
