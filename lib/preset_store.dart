import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/exam_preset.dart';

/// プリセットを端末ローカル（shared_preferences）に保存・読み込みするストア。
/// バックエンドは持たず、各ユーザーの端末内に JSON 文字列で永続化する。
class PresetStore {
  static const String _key = 'exam_presets';

  /// 保存済みプリセットを読み込む。未保存の場合はサンプルの初期値を返す。
  static Future<List<ExamPreset>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return defaults();
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ExamPreset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// プリセット一覧を保存する。
  static Future<void> save(List<ExamPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(presets.map((p) => p.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  /// 初回起動時に表示するサンプルプリセット（ユーザーは自由に編集・削除できる）。
  static List<ExamPreset> defaults() => const [
        ExamPreset(
          name: '東大入試1日目1限 国語',
          start: Duration(hours: 9, minutes: 30),
          end: Duration(hours: 12),
        ),
        ExamPreset(
          name: '東大入試1日目2限 数学',
          start: Duration(hours: 14),
          end: Duration(hours: 16, minutes: 30),
        ),
      ];
}
