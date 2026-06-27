import 'package:flutter/material.dart';

import 'app_colors.dart';

/// アプリのライト/ダーク [ThemeData] 定義。
///
/// 色はデザインシステム（DS）のトークンに合わせる。用途別の細かな色は
/// [AppColors]（ThemeExtension）側に持たせ、ここでは標準ウィジェットが参照する
/// `colorScheme` / 各コンポーネントテーマを揃える。
class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF009BFA);

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      surface: c.surface,
      error: c.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.screenBg,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.screenBg,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.dialogBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.dialogBorder),
        ),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.primary),
    );
  }
}
