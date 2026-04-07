import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk sabitleri
/// Kullanım: AppColors.primary, AppColors.success vb.
class AppColors {
  AppColors._(); // Instance oluşturulmasını engelle

  // ─────────────────────────────────────────────────────────────
  // ANA RENKLER
  // ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F5D75);
  static const Color secondary = Color(0xFF8FAF9F);
  static const Color accent = Color(0xFFC8D9D0);

  // ─────────────────────────────────────────────────────────────
  // ARKA PLAN & YÜZEY
  // ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────
  // METİN RENKLERİ
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────
  // BORDER & DIVIDER
  // ─────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // ─────────────────────────────────────────────────────────────
  // DURUM RENKLERİ
  // ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF7FB685);
  static const Color danger = Color(0xFFD98989);
  static const Color warning = Color(0xFFE6C98F);
  static const Color info = Color(0xFF4F5D75);

  // ─────────────────────────────────────────────────────────────
  // FİNANS ÖZEL RENKLERİ
  // ─────────────────────────────────────────────────────────────
  static const Color income = Color(0xFF7FB685);   // Gelir (success ile aynı)
  static const Color expense = Color(0xFFD98989);  // Gider (danger ile aynı)
  static const Color savings = Color(0xFF8FAF9F); // Birikim (secondary ile aynı)

  // ─────────────────────────────────────────────────────────────
  // GRADIENT'LAR
  // ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────────────────────
  // OPASITE VARYANTLARI (Hover, Disabled vb. için)
  // ─────────────────────────────────────────────────────────────
  static Color primaryLight = primary.withOpacity(0.1);
  static Color primaryMedium = primary.withOpacity(0.5);
  static Color successLight = success.withOpacity(0.1);
  static Color dangerLight = danger.withOpacity(0.1);
  static Color warningLight = warning.withOpacity(0.1);
}