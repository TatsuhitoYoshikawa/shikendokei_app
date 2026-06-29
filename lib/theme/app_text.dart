import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// アプリの日本語フォント。memento_mori と同じ構成:
/// - 見出し（[serif]）= Shippori Mincho（明朝）
/// - UI 本文（[ui]）= Zen Kaku Gothic New（ゴシック）
/// - 数字（[numeric]）= Roboto（等幅数字）
///
/// 既定の本文フォントは [AppTheme] で Zen Kaku Gothic New に設定する。
/// 見出し・数字など、用途が明確な箇所はここのヘルパーで個別に指定する。
class AppText {
  AppText._();

  /// 見出し（明朝・Shippori Mincho）。
  static TextStyle serif({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.shipporiMincho(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// UI 本文（ゴシック・Zen Kaku Gothic New）。
  static TextStyle ui({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.zenKakuGothicNew(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// 数字（Roboto・等幅数字）。時計表示・時刻・経過時間などに。
  static TextStyle numeric({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.roboto(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
