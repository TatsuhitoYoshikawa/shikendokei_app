import 'package:flutter/material.dart';

/// デザインシステム（DS）に基づくカスタムカラートークン。
///
/// `ColorScheme` だけでは表現しきれない用途別の色（時計の文字盤・目盛り、
/// セグメント、ホイール、終了オーバーレイ等）を [ThemeExtension] として保持し、
/// `Theme.of(context).extension<AppColors>()!` で参照する。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.screenBg,
    required this.surface,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSub,
    required this.textMuted,
    required this.hairline,
    required this.primary,
    required this.danger,
    // セグメント切替
    required this.segTrack,
    required this.segBorder,
    required this.segSelected,
    required this.segSelectedText,
    required this.segOther,
    required this.segShadow,
    // アナログ時計
    required this.clockFace,
    required this.clockFaceBorder,
    required this.clockTick,
    required this.clockNumber,
    required this.clockHand,
    required this.clockSecondHand,
    // 時刻設定ダイアログ（ホイール）
    required this.dialogBg,
    required this.dialogBorder,
    required this.wheelBand,
    required this.wheelNumDim,
    required this.wheelNumFaint,
    // オーバーレイ / 試験終了
    required this.overlayDim,
    required this.finishBg,
    required this.finishLabel,
    required this.finishTitle,
    required this.finishSub,
    // テーマ切替アイコン
    required this.themeIcon,
  });

  final Color screenBg;
  final Color surface;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textSub;
  final Color textMuted;
  final Color hairline;
  final Color primary;
  final Color danger;

  final Color segTrack;
  final Color segBorder;
  final Color segSelected;
  final Color segSelectedText;
  final Color segOther;

  /// 選択中セグメントの影（ライト時のみ薄い影、ダーク時は影なし）。
  final List<BoxShadow> segShadow;

  final Color clockFace;
  final Color clockFaceBorder;
  final Color clockTick;
  final Color clockNumber;
  final Color clockHand;
  final Color clockSecondHand;

  final Color dialogBg;
  final Color dialogBorder;
  final Color wheelBand;
  final Color wheelNumDim;
  final Color wheelNumFaint;

  final Color overlayDim;
  final Color finishBg;
  final Color finishLabel;
  final Color finishTitle;
  final Color finishSub;

  final Color themeIcon;

  static const light = AppColors(
    screenBg: Color(0xFFFCFCFD),
    surface: Color(0xFFFCFCFD),
    surfaceBorder: Color(0xFFD9D9E0),
    textPrimary: Color(0xFF1C2024),
    textSub: Color(0xFF60646C),
    textMuted: Color(0xFF8A8F98),
    hairline: Color(0xFFE8E8EC),
    primary: Color(0xFF009BFA),
    danger: Color(0xFFFF3D57),
    segTrack: Color(0xFFF0F0F3),
    segBorder: Color(0xFFD9D9E0),
    segSelected: Color(0xFFFCFCFD),
    segSelectedText: Color(0xFF1C2024),
    segOther: Color(0xFF60646C),
    segShadow: [
      BoxShadow(
        color: Color(0x1F020E2D), // rgba(2,14,45,.12)
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
    clockFace: Color(0xFFFFFFFF),
    clockFaceBorder: Color(0xFF1C2024),
    clockTick: Color(0xFF1C2024),
    clockNumber: Color(0xFF1C2024),
    clockHand: Color(0xFF1C2024),
    clockSecondHand: Color(0xFFFF3D57),
    dialogBg: Color(0xFFFCFCFD),
    dialogBorder: Color(0xFFE8E8EC),
    wheelBand: Color(0x1F009BFA), // rgba(0,155,250,.12)
    wheelNumDim: Color(0xFF8A8F98),
    wheelNumFaint: Color(0xFFCDCED6),
    overlayDim: Color(0x6B1C2024), // rgba(28,32,36,.42)
    finishBg: Color(0xF5FCFCFD), // rgba(252,252,253,.96)
    finishLabel: Color(0xFF8A8F98),
    finishTitle: Color(0xFF1C2024),
    finishSub: Color(0xFF60646C),
    themeIcon: Color(0xFFF5A623),
  );

  static const dark = AppColors(
    screenBg: Color(0xFF111113),
    surface: Color(0xFF18191B),
    surfaceBorder: Color(0xFF2E3135),
    textPrimary: Color(0xFFEDEEF0),
    textSub: Color(0xFFB0B4BA),
    textMuted: Color(0xFF696E77),
    hairline: Color(0xFF2E3135),
    primary: Color(0xFF009BFA),
    danger: Color(0xFFFF3D57),
    segTrack: Color(0xFF18191B),
    segBorder: Color(0xFF43484E),
    segSelected: Color(0xFF696E77),
    segSelectedText: Color(0xFFEDEEF0),
    segOther: Color(0xFFB0B4BA),
    segShadow: [],
    clockFace: Color(0xFF18191B),
    clockFaceBorder: Color(0xFF363A3F),
    clockTick: Color(0xFFB0B4BA),
    clockNumber: Color(0xFFEDEEF0),
    clockHand: Color(0xFFEDEEF0),
    clockSecondHand: Color(0xFFFF3D57),
    dialogBg: Color(0xFF212225),
    dialogBorder: Color(0xFF363A3F),
    wheelBand: Color(0x2E009BFA), // rgba(0,155,250,.18)
    wheelNumDim: Color(0xFF696E77),
    wheelNumFaint: Color(0xFF43484E),
    overlayDim: Color(0x8C000000), // rgba(0,0,0,.55)
    finishBg: Color(0xD6000000), // rgba(0,0,0,.84)
    finishLabel: Color(0xFF9DA1AA),
    finishTitle: Color(0xFFFFFFFF),
    finishSub: Color(0xFFCDCED6),
    themeIcon: Color(0xFFB0B4BA),
  );

  /// `Theme.of(context).extension<AppColors>()` の糖衣。
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? screenBg,
    Color? surface,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSub,
    Color? textMuted,
    Color? hairline,
    Color? primary,
    Color? danger,
    Color? segTrack,
    Color? segBorder,
    Color? segSelected,
    Color? segSelectedText,
    Color? segOther,
    List<BoxShadow>? segShadow,
    Color? clockFace,
    Color? clockFaceBorder,
    Color? clockTick,
    Color? clockNumber,
    Color? clockHand,
    Color? clockSecondHand,
    Color? dialogBg,
    Color? dialogBorder,
    Color? wheelBand,
    Color? wheelNumDim,
    Color? wheelNumFaint,
    Color? overlayDim,
    Color? finishBg,
    Color? finishLabel,
    Color? finishTitle,
    Color? finishSub,
    Color? themeIcon,
  }) {
    return AppColors(
      screenBg: screenBg ?? this.screenBg,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSub: textSub ?? this.textSub,
      textMuted: textMuted ?? this.textMuted,
      hairline: hairline ?? this.hairline,
      primary: primary ?? this.primary,
      danger: danger ?? this.danger,
      segTrack: segTrack ?? this.segTrack,
      segBorder: segBorder ?? this.segBorder,
      segSelected: segSelected ?? this.segSelected,
      segSelectedText: segSelectedText ?? this.segSelectedText,
      segOther: segOther ?? this.segOther,
      segShadow: segShadow ?? this.segShadow,
      clockFace: clockFace ?? this.clockFace,
      clockFaceBorder: clockFaceBorder ?? this.clockFaceBorder,
      clockTick: clockTick ?? this.clockTick,
      clockNumber: clockNumber ?? this.clockNumber,
      clockHand: clockHand ?? this.clockHand,
      clockSecondHand: clockSecondHand ?? this.clockSecondHand,
      dialogBg: dialogBg ?? this.dialogBg,
      dialogBorder: dialogBorder ?? this.dialogBorder,
      wheelBand: wheelBand ?? this.wheelBand,
      wheelNumDim: wheelNumDim ?? this.wheelNumDim,
      wheelNumFaint: wheelNumFaint ?? this.wheelNumFaint,
      overlayDim: overlayDim ?? this.overlayDim,
      finishBg: finishBg ?? this.finishBg,
      finishLabel: finishLabel ?? this.finishLabel,
      finishTitle: finishTitle ?? this.finishTitle,
      finishSub: finishSub ?? this.finishSub,
      themeIcon: themeIcon ?? this.themeIcon,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      screenBg: c(screenBg, other.screenBg),
      surface: c(surface, other.surface),
      surfaceBorder: c(surfaceBorder, other.surfaceBorder),
      textPrimary: c(textPrimary, other.textPrimary),
      textSub: c(textSub, other.textSub),
      textMuted: c(textMuted, other.textMuted),
      hairline: c(hairline, other.hairline),
      primary: c(primary, other.primary),
      danger: c(danger, other.danger),
      segTrack: c(segTrack, other.segTrack),
      segBorder: c(segBorder, other.segBorder),
      segSelected: c(segSelected, other.segSelected),
      segSelectedText: c(segSelectedText, other.segSelectedText),
      segOther: c(segOther, other.segOther),
      segShadow: t < 0.5 ? segShadow : other.segShadow,
      clockFace: c(clockFace, other.clockFace),
      clockFaceBorder: c(clockFaceBorder, other.clockFaceBorder),
      clockTick: c(clockTick, other.clockTick),
      clockNumber: c(clockNumber, other.clockNumber),
      clockHand: c(clockHand, other.clockHand),
      clockSecondHand: c(clockSecondHand, other.clockSecondHand),
      dialogBg: c(dialogBg, other.dialogBg),
      dialogBorder: c(dialogBorder, other.dialogBorder),
      wheelBand: c(wheelBand, other.wheelBand),
      wheelNumDim: c(wheelNumDim, other.wheelNumDim),
      wheelNumFaint: c(wheelNumFaint, other.wheelNumFaint),
      overlayDim: c(overlayDim, other.overlayDim),
      finishBg: c(finishBg, other.finishBg),
      finishLabel: c(finishLabel, other.finishLabel),
      finishTitle: c(finishTitle, other.finishTitle),
      finishSub: c(finishSub, other.finishSub),
      themeIcon: c(themeIcon, other.themeIcon),
    );
  }
}
