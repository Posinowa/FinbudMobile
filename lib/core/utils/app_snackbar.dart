// lib/core/utils/app_snackbar.dart

import 'package:flutter/material.dart';
import '../constants/app_color.dart';

/// Uygulama genelinde tutarlı SnackBar gösterimi için utility sınıfı.
/// Tüm ekranlarda aynı format kullanılır.
///
/// Kullanım:
///   AppSnackBar.showError(context, 'Hata mesajı');
///   AppSnackBar.showSuccess(context, 'Başarılı mesaj');
///   AppSnackBar.showInfo(context, 'Bilgi mesajı');
///   AppSnackBar.showWarning(context, 'Uyarı mesajı');
///   AppSnackBar.showError(context, 'Hata', actionLabel: 'Tekrar Dene', onAction: () {});
class AppSnackBar {
  AppSnackBar._();

  /// Hata mesajı göster (kırmızı)
  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.danger,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Başarı mesajı göster (yeşil)
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Bilgi mesajı göster (gri-mavi)
  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Uyarı mesajı göster (sarı)
  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
