import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 表示時刻（時/分/秒）を受け取り、文字盤・目盛り・3本の針を描画するアナログ時計。
///
/// 針の角度は既存 JS (`tokei.js` の GetTimeAnalogue/SetTimeAnalogue) の計算を踏襲:
///   時針 = 時 * 30 + 分 * 0.5 度
///   分針 = 分 * 6 度
///   秒針 = 秒 * 6 度
class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.time});

  /// 0:00:00 を起点とした経過時間で表現した「現在の表示時刻」。
  final Duration time;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          painter: _ClockPainter(time),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.time);

  final Duration time;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    _drawFace(canvas, center, radius);
    _drawTicks(canvas, center, radius);
    _drawNumbers(canvas, center, radius);
    _drawHands(canvas, center, radius);

    // 中心の丸
    canvas.drawCircle(center, radius * 0.03, Paint()..color = Colors.black);
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    final fill = Paint()
      ..color = const Color(0x33FFF3D9) // rgba(255,243,217,0.2) 相当
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.015;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, border);
  }

  /// 60本の目盛り。5分ごと（i % 5 == 0）は太く長く。
  void _drawTicks(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 60; i++) {
      final isMajor = i % 5 == 0;
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = isMajor ? radius * 0.02 : radius * 0.01;
      final tickLength = isMajor ? radius * 0.08 : radius * 0.04;
      final angle = i * 6 * math.pi / 180;
      final outer = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      final inner = Offset(
        center.dx + (radius - tickLength) * math.sin(angle),
        center.dy - (radius - tickLength) * math.cos(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  /// 12 / 3 / 6 / 9 の数字。
  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    const numbers = {0: '12', 3: '3', 6: '6', 9: '9'};
    final fontSize = radius * 0.13;
    numbers.forEach((hour, label) {
      final angle = hour * 30 * math.pi / 180;
      final position = Offset(
        center.dx + (radius - radius * 0.2) * math.sin(angle),
        center.dy - (radius - radius * 0.2) * math.cos(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        position - Offset(tp.width / 2, tp.height / 2),
      );
    });
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    final totalSeconds = time.inSeconds;
    final sec = totalSeconds % 60;
    final min = (totalSeconds ~/ 60) % 60;
    final hour = (totalSeconds ~/ 3600) % 12;

    final degHour = hour * 30 + min * 0.5;
    final degMin = min * 6.0;
    final degSec = sec * 6.0;

    // 時針
    _drawHand(
      canvas,
      center,
      degHour,
      radius * 0.5,
      radius * 0.02,
      Colors.black,
    );
    // 分針
    _drawHand(
      canvas,
      center,
      degMin,
      radius * 0.7,
      radius * 0.012,
      Colors.black,
    );
    // 秒針
    _drawHand(
      canvas,
      center,
      degSec,
      radius * 0.8,
      radius * 0.005,
      Colors.red,
    );
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
    final end = Offset(
      center.dx + length * math.sin(angle),
      center.dy - length * math.cos(angle),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.time != time;
}
