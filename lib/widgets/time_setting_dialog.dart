import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 時・分・秒を3列のホイールで設定するダイアログ。
/// 開始時刻・終了時刻の設定で共用する。
///
/// 各列にそれぞれ独立したハイライト帯を中央に敷き、「時・分・秒が別々に変更できる」
/// ことが一目で分かるようにする。
///
/// 初期値 [initial] を表示し、「設定」確定で選択した [Duration] を返す。
/// キャンセル時は null を返す。
class TimeSettingDialog extends StatefulWidget {
  const TimeSettingDialog({
    super.key,
    required this.title,
    required this.initial,
  });

  final String title;
  final Duration initial;

  /// ダイアログを表示し、確定された [Duration] を返すヘルパー。
  static Future<Duration?> show(
    BuildContext context, {
    required String title,
    required Duration initial,
  }) {
    return showDialog<Duration>(
      context: context,
      builder: (_) => TimeSettingDialog(title: title, initial: initial),
    );
  }

  @override
  State<TimeSettingDialog> createState() => _TimeSettingDialogState();
}

class _TimeSettingDialogState extends State<TimeSettingDialog> {
  late int _hour;
  late int _minute;
  late int _second;

  static const double _itemExtent = 34;

  @override
  void initState() {
    super.initState();
    final total = widget.initial.inSeconds;
    _hour = (total ~/ 3600) % 24;
    _minute = (total ~/ 60) % 60;
    _second = total % 60;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      title: Text(widget.title, textAlign: TextAlign.center),
      content: SizedBox(
        width: 252,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _wheel(
                    colors: colors,
                    max: 24,
                    value: _hour,
                    onChanged: (v) => setState(() => _hour = v),
                  ),
                ),
                _colon(colors),
                Expanded(
                  child: _wheel(
                    colors: colors,
                    max: 60,
                    value: _minute,
                    onChanged: (v) => setState(() => _minute = v),
                  ),
                ),
                _colon(colors),
                Expanded(
                  child: _wheel(
                    colors: colors,
                    max: 60,
                    value: _second,
                    onChanged: (v) => setState(() => _second = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _unitLabel(colors, '時'),
                const SizedBox(width: 8),
                _unitLabel(colors, '分'),
                const SizedBox(width: 8),
                _unitLabel(colors, '秒'),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSub,
                    side: BorderSide(color: colors.surfaceBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    Duration(hours: _hour, minutes: _minute, seconds: _second),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '設定',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colon(AppColors colors) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.wheelNumDim,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );

  Widget _unitLabel(AppColors colors, String text) => Expanded(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
          ),
        ),
      );

  Widget _wheel({
    required AppColors colors,
    required int max,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: _itemExtent * 5, // 中央 + 上下2行
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 列ごとの独立したハイライト帯。
          Center(
            child: Container(
              height: _itemExtent,
              decoration: BoxDecoration(
                color: colors.wheelBand,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(initialItem: value),
            itemExtent: _itemExtent,
            perspective: 0.004,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max,
              builder: (context, index) {
                final distance = (index - value).abs();
                final TextStyle style;
                if (distance == 0) {
                  style = TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  );
                } else if (distance == 1) {
                  style = TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colors.wheelNumDim,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  );
                } else {
                  style = TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.wheelNumFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  );
                }
                return Center(
                  child: Text(index.toString().padLeft(2, '0'), style: style),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
