import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// 表示時刻を `HH:MM:SS` の大きな等幅表示で描画するデジタル時計。
class DigitalClock extends StatelessWidget {
  const DigitalClock({super.key, required this.time});

  /// 0:00:00 を起点とした経過時間で表現した「現在の表示時刻」。
  final Duration time;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final totalSeconds = time.inSeconds;
    final hour = (totalSeconds ~/ 3600) % 24;
    final min = (totalSeconds ~/ 60) % 60;
    final sec = totalSeconds % 60;
    final text = '${_two(hour)}:${_two(min)}:${_two(sec)}';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: AppText.numeric(
          size: 96,
          weight: FontWeight.bold,
          color: colors.textPrimary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
