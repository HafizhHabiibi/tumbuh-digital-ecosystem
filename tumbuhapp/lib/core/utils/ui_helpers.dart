import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

class UiHelpers {
  UiHelpers._();

  static InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.bodySecondary,
      filled: true,
      fillColor: fillColor ?? AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.statusBurukText),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.statusBurukText, width: 2),
      ),
    );
  }
}
