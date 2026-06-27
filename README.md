# 試験時計 (Shiken Dokei)

試験本番のシミュレーションとして、設定した**開始時刻**から時を刻むデジタル/アナログ時計を表示する Flutter アプリです。試験の実際の開始時刻に合わせて時計を進め、本番同様の時間感覚でテストを受ける体験を提供します。

> 旧バージョンは Flask + JavaScript 実装でしたが、Flutter（全プラットフォーム対応）に置き換えました。

## 機能

- **1画面構成**
- **デジタル / アナログ表示の切り替え**（上部のセグメントボタン）
- **開始時刻の設定**（時・分・秒）— 設定すると時計はその時刻にセットされ、進行は止まります
- **終了時刻の設定**（時・分・秒）
- **プリセット**（名称＋開始時刻＋終了時刻）— 「東大入試1日目1限 国語 / 開始 09:30 / 終了 12:00」のようなセットを保存しておき、選択するだけで開始・終了時刻を一括設定できます。アプリ内で追加・編集・削除でき、**バックエンド不要・端末ローカル**（`shared_preferences`）に保存されます
- **開始 / 停止ボタン** — 開始で時を刻み始め、押すと「停止」に変わり止められます
- **設定操作でも進行は停止**します
- **終了時刻に到達すると音が鳴り、「試験終了」のオーバーレイを表示**します。「元の画面に戻る」ボタンで元の表示に戻ります（画面遷移はしません）

## 構成

```
lib/
  main.dart                       アプリのエントリポイント
  clock_screen.dart               メイン画面（状態機械・タイマー・終了オーバーレイ）
  preset_store.dart               プリセットの端末ローカル保存（shared_preferences）
  models/
    exam_preset.dart              プリセットのデータモデル（名称・開始・終了）
  widgets/
    analog_clock.dart             CustomPainter によるアナログ時計
    digital_clock.dart            HH:MM:SS デジタル表示
    time_setting_dialog.dart      時/分/秒のホイールピッカー（開始・終了で共用）
    preset_edit_dialog.dart       プリセットの新規作成・編集ダイアログ
    preset_manager_sheet.dart     プリセットの一覧・選択・追加・編集・削除
assets/
  sounds/alarm.wav                試験終了アラーム音
```

依存パッケージ:
- [`audioplayers`](https://pub.dev/packages/audioplayers)（アラーム再生）
- [`shared_preferences`](https://pub.dev/packages/shared_preferences)（プリセットの端末ローカル保存）

## セットアップと実行（実機検証用 PC）

このリポジトリには `lib/`・`pubspec.yaml`・`assets/` のみ含まれます。各 OS のプラットフォーム雛形は次の手順で生成してください（`lib/`・`pubspec.yaml`・`assets/` は上書きされません）。

```bash
# 1. プラットフォーム雛形（android/ ios/ web/ など）を生成
flutter create .

# 2. 依存を取得
flutter pub get

# 3. 静的解析（任意）
flutter analyze

# 4. 実機・エミュレータ・ブラウザで起動
flutter devices          # 接続中の端末を確認
flutter run              # 接続した実機 / エミュレータで起動
flutter run -d chrome    # Web ブラウザで起動する場合
```

> Flutter SDK のインストールが必要です: https://docs.flutter.dev/get-started/install

## 動作確認チェックリスト

- [ ] アナログ / デジタルの切り替えが効く
- [ ] 開始時刻を設定すると時・分・秒が変更でき、時計がその時刻にセットされる
- [ ] 開始ボタンで秒が進み、「停止」ボタンに変わって止められる
- [ ] 時刻設定の操作で進行が止まる
- [ ] 終了時刻を直近に設定して開始すると、終了時刻で音が鳴り「試験終了」が表示される
- [ ] 「元の画面に戻る」でオーバーレイが閉じる（画面遷移しない）
- [ ] プリセットを追加・編集・削除でき、アプリを再起動しても保持される
- [ ] プリセットを選択すると開始時刻・終了時刻が一括でセットされる
