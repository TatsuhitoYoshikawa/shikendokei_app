import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shikendokei/main.dart';
import 'package:shikendokei/theme/theme_controller.dart';

void main() {
  setUp(() {
    // プリセット読み込み・テーマ設定（shared_preferences）をテスト用にモックする。
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('開始/停止ボタンと切替が表示される', (WidgetTester tester) async {
    // 大きなアナログ時計を含む縦長レイアウトが収まるよう、実機相当の画面サイズにする。
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeController = ThemeController();
    await themeController.load();
    await tester.pumpWidget(ShikenDokeiApp(themeController: themeController));
    await tester.pump(); // プリセットの非同期読み込みを反映。

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
