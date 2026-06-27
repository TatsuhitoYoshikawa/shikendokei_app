import 'package:flutter/material.dart';

/// 時・分・秒を3列のホイールで設定するダイアログ。
/// 開始時刻・終了時刻の設定で共用する。
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
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _wheel(
              max: 24,
              value: _hour,
              label: '時',
              onChanged: (v) => setState(() => _hour = v),
            ),
            _colon(),
            _wheel(
              max: 60,
              value: _minute,
              label: '分',
              onChanged: (v) => setState(() => _minute = v),
            ),
            _colon(),
            _wheel(
              max: 60,
              value: _second,
              label: '秒',
              onChanged: (v) => setState(() => _second = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            Duration(hours: _hour, minutes: _minute, seconds: _second),
          ),
          child: const Text('設定'),
        ),
      ],
    );
  }

  Widget _colon() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(':', style: TextStyle(fontSize: 24)),
      );

  Widget _wheel({
    required int max,
    required int value,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          height: 140,
          child: ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(initialItem: value),
            itemExtent: 40,
            perspective: 0.005,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max,
              builder: (context, index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
