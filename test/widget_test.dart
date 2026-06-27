import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shikendokei/main.dart';

void main() {
  testWidgets('開始/停止ボタンと切替が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const ShikenDokeiApp());

    // タイトルと主要なボタンが表示されている。
    expect(find.text('試験時計'), findsOneWidget);
    expect(find.text('アナログ'), findsOneWidget);
    expect(find.text('デジタル'), findsOneWidget);
    expect(find.text('開始'), findsOneWidget);

    // 開始ボタンを押すと「停止」に変わる。
    await tester.tap(find.text('開始'));
    await tester.pump();
    expect(find.text('停止'), findsOneWidget);

    // タイマーを止めて後始末（保留タイマーを残さない）。
    await tester.tap(find.text('停止'));
    await tester.pump();
    expect(find.text('開始'), findsOneWidget);
  });
}
