/// 試験のプリセット。名称・開始時刻・終了時刻のセット。
///
/// 時刻は 0:00:00 を起点とした経過時間 [Duration] で保持する。
class ExamPreset {
  const ExamPreset({
    required this.name,
    required this.start,
    required this.end,
  });

  final String name;
  final Duration start;
  final Duration end;

  ExamPreset copyWith({String? name, Duration? start, Duration? end}) {
    return ExamPreset(
      name: name ?? this.name,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start.inSeconds,
        'end': end.inSeconds,
      };

  factory ExamPreset.fromJson(Map<String, dynamic> json) => ExamPreset(
        name: json['name'] as String,
        start: Duration(seconds: json['start'] as int),
        end: Duration(seconds: json['end'] as int),
      );
}
