import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// 表示時刻（時/分/秒）を受け取り、文字盤・目盛り・3本の針を描画するアナログ時計。
///
/// デザイン（DS ハンドオフの `WallClock`）に準拠。viewBox 210×210・中心 (105,105)・
/// 半径 84 を基準に、与えられたサイズへスケールして描画する。
/// 針の角度計算は既存どおり:
///   時針 = 時 * 30 + 分 * 0.5 度 / 分針 = 分 * 6 度 / 秒針 = 秒 * 6 度
class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.time});

  /// 0:00:00 を起点とした経過時間で表現した「現在の表示時刻」。
  final Duration time;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _ClockPainter(time: time, colors: colors),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.time, required this.colors});

  final Duration time;
  final AppColors colors;

  // デザインの viewBox（210×210）基準値。
  static const double _vb = 210;
  static const double _vbCenter = 105;
  static const double _vbRadius = 84;

  @override
  void paint(Canvas canvas, Size size) {
    // viewBox 基準で描画し、実サイズへ等倍スケールする。
    final scale = math.min(size.width, size.height) / _vb;
    canvas.save();
    canvas.translate(
      (size.width - _vb * scale) / 2,
      (size.height - _vb * scale) / 2,
    );
    canvas.scale(scale);

    const center = Offset(_vbCenter, _vbCenter);
    const r = _vbRadius;

    _drawFace(canvas, center, r);
    _drawTicks(canvas, center, r);
    _drawNumbers(canvas, center, r);
    _drawHands(canvas, center);

    canvas.restore();
  }

  void _drawFace(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = colors.clockFace
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = colors.clockFaceBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  /// 60本の目盛り。5分ごと（major）は太く長く・不透明、minor は細く短く半透明。
  void _drawTicks(Canvas canvas, Offset center, double r) {
    for (var i = 0; i < 60; i++) {
      final isMajor = i % 5 == 0;
      final len = isMajor ? 13.0 : 6.0;
      final paint = Paint()
        ..color = colors.clockTick.withValues(alpha: isMajor ? 1.0 : 0.45)
        ..strokeWidth = isMajor ? 2.8 : 1.0
        ..strokeCap = StrokeCap.round;
      final angle = i * 6 * math.pi / 180;
      final outer = Offset(
        center.dx + r * math.sin(angle),
        center.dy - r * math.cos(angle),
      );
      final inner = Offset(
        center.dx + (r - len) * math.sin(angle),
        center.dy - (r - len) * math.cos(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  /// 12 / 3 / 6 / 9 の数字（半径 R-24 の位置）。
  void _drawNumbers(Canvas canvas, Offset center, double r) {
    const numbers = {0: '12', 3: '3', 6: '6', 9: '9'};
    numbers.forEach((hour, label) {
      final angle = hour * 30 * math.pi / 180;
      final position = Offset(
        center.dx + (r - 24) * math.sin(angle),
        center.dy - (r - 24) * math.cos(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: AppText.numeric(
            size: 16,
            weight: FontWeight.w700,
            color: colors.clockNumber,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, position - Offset(tp.width / 2, tp.height / 2));
    });
  }

  void _drawHands(Canvas canvas, Offset center) {
    final totalSeconds = time.inSeconds;
    final sec = totalSeconds % 60;
    final min = (totalSeconds ~/ 60) % 60;
    final hour = (totalSeconds ~/ 3600) % 12;

    final degHour = hour * 30 + min * 0.5;
    final degMin = min * 6.0;
    final degSec = sec * 6.0;

    _drawHand(canvas, center, degHour, 46, 5.5, colors.clockHand);
    _drawHand(canvas, center, degMin, 66, 3.6, colors.clockHand);
    _drawHand(canvas, center, degSec, 73, 1.6, colors.clockSecondHand);

    // 中心キャップ（秒針色の小円 + 文字盤色の極小円）。
    canvas.drawCircle(center, 5, Paint()..color = colors.clockSecondHand);
    canvas.drawCircle(center, 2, Paint()..color = colors.clockFace);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double degrees,
    double length,
    double width,
    Color color,
  ) {
    final angle = degrees * math.pi / 180;
    // デザインに合わせ、中心の反対側へ少し（長さの16%）伸ばす。
    final tail = Offset(
      center.dx - length * 0.16 * math.sin(angle),
      center.dy + length * 0.16 * math.cos(angle),
    );
    final tip = Offset(
      center.dx + length * math.sin(angle),
      center.dy - length * math.cos(angle),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, paint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.colors != colors;
}
