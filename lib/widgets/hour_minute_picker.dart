import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// 時・分を2列のホイールで設定するダイアログ（秒は扱わない）。
/// 試験種類の開始/終了時刻の設定に使う。
///
/// レイアウトはすべて固定サイズで構成し、ダイアログの入れ子（試験種類の
/// 追加/編集ダイアログ上）で開いても崩れないようにしている。
class HourMinutePicker extends StatefulWidget {
  const HourMinutePicker({
    super.key,
    required this.title,
    required this.initial,
  });

  final String title;
  final Duration initial;

  /// ダイアログを表示し、確定された [Duration]（時・分、秒は0）を返す。
  static Future<Duration?> show(
    BuildContext context, {
    required String title,
    required Duration initial,
  }) {
    return showDialog<Duration>(
      context: context,
      builder: (_) => HourMinutePicker(title: title, initial: initial),
    );
  }

  @override
  State<HourMinutePicker> createState() => _HourMinutePickerState();
}

class _HourMinutePickerState extends State<HourMinutePicker> {
  late int _hour;
  late int _minute;

  static const double _itemExtent = 34;
  static const double _wheelWidth = 76;
  static const int _visibleRows = 5; // 中央 + 上下2行

  @override
  void initState() {
    super.initState();
    final total = widget.initial.inSeconds;
    _hour = (total ~/ 3600) % 24;
    _minute = (total ~/ 60) % 60;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      title: Text(widget.title, textAlign: TextAlign.center),
      content: SizedBox(
        width: _wheelWidth * 2 + 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _itemExtent * _visibleRows,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _wheel(
                    colors: colors,
                    max: 24,
                    value: _hour,
                    onChanged: (v) => setState(() => _hour = v),
                  ),
                  _colon(colors),
                  _wheel(
                    colors: colors,
                    max: 60,
                    value: _minute,
                    onChanged: (v) => setState(() => _minute = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _unitLabel(colors, '時'),
                const SizedBox(width: 24),
                _unitLabel(colors, '分'),
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
                    Duration(hours: _hour, minutes: _minute),
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          ':',
          style: AppText.numeric(
            size: 18,
            weight: FontWeight.w600,
            color: colors.wheelNumDim,
          ),
        ),
      );

  Widget _unitLabel(AppColors colors, String text) => SizedBox(
        width: _wheelWidth,
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
      width: _wheelWidth,
      height: _itemExtent * _visibleRows,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 中央のハイライト帯。
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
                  style = AppText.numeric(
                    size: 21,
                    weight: FontWeight.w700,
                    color: colors.textPrimary,
                  );
                } else if (distance == 1) {
                  style = AppText.numeric(
                    size: 18,
                    weight: FontWeight.w500,
                    color: colors.wheelNumDim,
                  );
                } else {
                  style = AppText.numeric(
                    size: 16,
                    weight: FontWeight.w500,
                    color: colors.wheelNumFaint,
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
