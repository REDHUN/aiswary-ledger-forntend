import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Deep Emerald & Teal - Aiswarya Financial Sangham)
  static const Color primary = Color(0xFF0F5132);
  static const Color primaryLight = Color(0xFF198754);
  static const Color primaryDark = Color(0xFF0A3622);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentAmber = Color(0xFFFFC107);

  // Status & Financial Indicators
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Background & Surface
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgCard = Colors.white;
  static const Color textDark = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFDEE2E6);

  // Account Category Accent Colors
  static const Color accountLoan = Color(0xFFC62828);
  static const Color accountDeposit = Color(0xFF2E7D32);
  static const Color accountFine = Color(0xFFEF6C00);
  static const Color accountFinancialAid = Color(0xFF6A1B9A);
  static const Color accountContribution = Color(0xFF1565C0);
  static const Color accountInterest = Color(0xFF00838F);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0A3622), Color(0xFF198754)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF4F6F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
