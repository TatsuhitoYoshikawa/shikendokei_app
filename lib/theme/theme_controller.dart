import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ全体のテーマ（ライト/ダーク/OS追従）を保持・永続化するコントローラ。
///
/// - 初期値は OS 追従（[ThemeMode.system]）。
/// - AppBar 右上アイコンのタップで「現在の実効テーマ」を反転して light/dark を
///   セットし、端末（shared_preferences）に保存する。
/// - 次回起動時は保存値を復元して適用する。
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// 起動時に保存済みのテーマ設定を復元する（無ければ system のまま）。
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_key)) {
      case 'light':
        _mode = ThemeMode.light;
      case 'dark':
        _mode = ThemeMode.dark;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// 現在の実効テーマを反転して light/dark をセットし、保存する。
  Future<void> toggle(BuildContext context) async {
    final isDarkNow = _mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
        : _mode == ThemeMode.dark;
    _mode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
