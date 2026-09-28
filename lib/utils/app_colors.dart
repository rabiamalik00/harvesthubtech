import 'package:flutter/material.dart';

/// Premium Botanical & Agricultural Color Palette
/// Inspired by modern eco-luxury UI designs (Mint, Forest, Sage, Warm Gold)
class AppColors {
  // Botanical Primary Greens
  static const Color primary = Color(0xFF2D6A4F);       // Deep Sage Forest
  static const Color primaryDark = Color(0xFF1B4332);   // Jungle Night
  static const Color primaryLight = Color(0xFF40916C);  // Emerald Meadow
  static const Color primaryAccent = Color(0xFF52B788); // Soft Spring Mint
  static const Color primarySurface = Color(0xFFE8F5EE); // Gentle Mint Canvas

  // Soft Natural Backgrounds
  static const Color background = Color(0xFFF6FAF6);    // Crisp Botanical White
  static const Color surface = Colors.white;            // Pure Card Surface
  static const Color cardBg = surface; // Alias for surface
  static const Color accentLight = accent; // Alias for accent
  static const Color surfaceGlass = Color(0xF2FFFFFF);  // Frosted Glass (95% opacity)
  static const Color cardBorder = Color(0xFFE5EDE5);    // Ultra Soft Botanical Border
  static const Color divider = Color(0xFFEDF4ED);

  // Golden Sun Accents (Mandi & Harvest Gold)
  static const Color accent = Color(0xFFE76F51);        // Terracotta Warmth
  static const Color gold = Color(0xFFF4A261);          // Ripe Wheat Gold
  static const Color accentSurface = Color(0xFFFFF3ED); // Warm Sun Cream

  // Organic Certified Greens
  static const Color organicBadge = Color(0xFF2D6A4F);
  static const Color organicBg = Color(0xFFD8F3DC);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF1C2D24);   // Deep Forest Slate
  static const Color textSecondary = Color(0xFF52796F); // Muted Sage
  static const Color textLight = Color(0xFF8FA89B);     // Subdued Leaf

  // Status & Utility Colors
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFE76F51);
  static const Color danger = Color(0xFFD90429);
  static const Color info = Color(0xFF2A9D8F);

  // Gentle Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFE8F5EE), Color(0xFFD8F3DC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF9FCF9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
