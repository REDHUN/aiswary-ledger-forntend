import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class LanguageViewModel extends ChangeNotifier {
  final StorageService _storageService;

  Locale _locale = const Locale('ml');

  LanguageViewModel(this._storageService) {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;
  bool get isMalayalam => _locale.languageCode == 'ml';

  void _loadSavedLanguage() {
    final savedLang = _storageService.getString('app_language');
    if (savedLang != null && (savedLang == 'ml' || savedLang == 'en')) {
      _locale = Locale(savedLang);
    } else {
      _locale = const Locale('ml');
      _storageService.setString('app_language', 'ml');
    }
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    await _storageService.setString('app_language', languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final nextLang = isMalayalam ? 'en' : 'ml';
    await setLanguage(nextLang);
  }
}
