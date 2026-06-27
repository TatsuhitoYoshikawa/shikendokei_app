import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'models/exam_preset.dart';
import 'preset_store.dart';
import 'theme/app_colors.dart';
import 'theme/theme_controller.dart';
import 'widgets/analog_clock.dart';
import 'widgets/digital_clock.dart';
import 'widgets/preset_manager_sheet.dart';
import 'widgets/time_setting_dialog.dart';

/// 試験時計のメイン画面（1画面構成）。
///
/// 設定した開始時刻を起点に、開始ボタンで1秒ずつ時を刻む。終了時刻に達すると
/// 音を鳴らし「試験終了」オーバーレイを表示する（画面遷移はしない）。
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key, required this.themeController});

  /// ライト/ダーク切替を司るコントローラ（AppBar のアイコンから操作）。
  final ThemeController themeController;

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  /// 表示モード（true: アナログ / false: デジタル）。既存実装に合わせ初期はアナログ。
  bool _isAnalog = true;

  /// 開始時刻・終了時刻（0:00:00 起点の経過時間で保持）。
  Duration _startTime = const Duration(hours: 9, minutes: 30);
  Duration _endTime = const Duration(hours: 14);

  /// 現在表示中のシミュレート時刻。開始前は開始時刻と同じ。
  Duration _current = const Duration(hours: 9, minutes: 30);

  /// 進行中フラグ（開始/停止ボタンの表示切替に使用）。
  bool _isRunning = false;

  /// 「試験終了」オーバーレイの表示フラグ。
  bool _examFinished = false;

  /// 選択中のプリセット名（手動で時刻を変更した場合は null）。
  String? _presetName;

  Timer? _timer;
  final AudioPlayer _player = AudioPlayer();

  /// 端末ローカルに保存された開始/終了時刻のプリセット一覧。
  List<ExamPreset> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await PresetStore.load();
    if (mounted) setState(() => _presets = presets);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ---- 時の刻み制御 -------------------------------------------------------

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _isRunning = false);
  }

  void _tick() {
    final next = _current + const Duration(seconds: 1);
    if (next >= _endTime) {
      // 終了時刻に到達：終了時刻ちょうどで止めてオーバーレイを出す。
      setState(() => _current = _endTime);
      _finishExam();
    } else {
      setState(() => _current = next);
    }
  }

  Future<void> _finishExam() async {
    _stop();
    setState(() => _examFinished = true);
    try {
      await _player.play(AssetSource('sounds/alarm.wav'));
    } catch (_) {
      // 音声再生に失敗してもオーバーレイ表示は継続する。
    }
  }

  void _dismissOverlay() {
    setState(() => _examFinished = false);
  }

  // ---- 時刻設定 -----------------------------------------------------------

  Future<void> _editStartTime() async {
    _stop(); // 設定ボタン押下でも時の刻みは止まる。
    final result = await TimeSettingDialog.show(
      context,
      title: '開始時刻を設定',
      initial: _startTime,
    );
    if (result != null) {
      setState(() {
        _startTime = result;
        _current = result; // 開始時刻にリセット。
        _presetName = null; // 手動変更したのでプリセット名を消す。
      });
    }
  }

  Future<void> _editEndTime() async {
    _stop(); // 設定ボタン押下でも時の刻みは止まる。
    final result = await TimeSettingDialog.show(
      context,
      title: '終了時刻を設定',
      initial: _endTime,
    );
    if (result != null) {
      setState(() {
        _endTime = result;
        _presetName = null; // 手動変更したのでプリセット名を消す。
      });
    }
  }

  // ---- プリセット ---------------------------------------------------------

  Future<void> _openPresets() async {
    _stop(); // 設定操作と同様、時の刻みは止める。
    final selected = await PresetManagerSheet.show(
      context,
      presets: _presets,
      selectedName: _presetName,
      onChanged: (updated) {
        setState(() => _presets = updated);
        PresetStore.save(updated);
      },
    );
    if (selected != null) {
      _applyPreset(selected);
    }
  }

  void _applyPreset(ExamPreset preset) {
    setState(() {
      _startTime = preset.start;
      _endTime = preset.end;
      _current = preset.start; // 開始時刻にセット。
      _presetName = preset.name; // 選択したプリセット名を時計上部に表示。
    });
  }

  // ---- UI -----------------------------------------------------------------

  String _hms(Duration d) {
    final h = (d.inSeconds ~/ 3600) % 24;
    final m = (d.inSeconds ~/ 60) % 60;
    final s = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  String _hm(Duration d) {
    final h = (d.inSeconds ~/ 3600) % 24;
    final m = (d.inSeconds ~/ 60) % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}';
  }

  /// 開始時刻からの経過時間（負にはしない）。
  Duration get _elapsed {
    final e = _current - _startTime;
    return e.isNegative ? Duration.zero : e;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('試験時計'),
        actions: [
          IconButton(
            iconSize: 24,
            tooltip: isDark ? 'ライトテーマに切替' : 'ダークテーマに切替',
            onPressed: () => widget.themeController.toggle(context),
            icon: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: colors.themeIcon,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          _buildMain(context, colors),
          if (_examFinished) _buildFinishOverlay(context, colors),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context, AppColors colors) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 22),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _segmentedControl(colors),
                      const SizedBox(height: 20),
                      _presetNameRow(colors),
                      const SizedBox(height: 14),

                      // アナログ / デジタル時計。画面幅いっぱいに拡大（最大 360）。
                      SizedBox.square(
                        dimension: (constraints.maxWidth - 12)
                            .clamp(222.0, 360.0),
                        child: Center(
                          child: _isAnalog
                              ? AnalogClock(time: _current)
                              : DigitalClock(time: _current),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 経過時間キャプション。
                      Text(
                        '経過 ${_hms(_elapsed)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.textMuted,
                          letterSpacing: 0.08 * 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),

                      const Expanded(child: SizedBox(height: 16)),

                      _startStopButton(colors),
                      const SizedBox(height: 14),
                      _timeCardsRow(colors),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _segmentedControl(AppColors colors) {
    return Container(
      width: 204,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.segTrack,
        border: Border.all(color: colors.segBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _segment(colors, label: 'アナログ', selected: _isAnalog,
              onTap: () => setState(() => _isAnalog = true)),
          _segment(colors, label: 'デジタル', selected: !_isAnalog,
              onTap: () => setState(() => _isAnalog = false)),
        ],
      ),
    );
  }

  Widget _segment(
    AppColors colors, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? colors.segSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: selected ? colors.segShadow : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? colors.segSelectedText : colors.segOther,
            ),
          ),
        ),
      ),
    );
  }

  Widget _presetNameRow(AppColors colors) {
    final hasPreset = _presetName != null;
    return InkWell(
      onTap: _openPresets,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                hasPreset ? _presetName! : 'プリセットを選択',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasPreset ? colors.textSub : colors.textMuted,
                  letterSpacing: 0.04 * 13,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 16, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _startStopButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: _isRunning ? _stop : _start,
        icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow, size: 22),
        label: Text(
          _isRunning ? '停止' : '開始',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _isRunning ? colors.danger : colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _timeCardsRow(AppColors colors) {
    return Row(
      children: [
        _timeCard(
          colors,
          label: '開始時刻',
          value: _hm(_startTime),
          onTap: _editStartTime,
        ),
        const SizedBox(width: 12),
        _timeCard(
          colors,
          label: '終了時刻',
          value: _hm(_endTime),
          onTap: _editEndTime,
        ),
      ],
    );
  }

  Widget _timeCard(
    AppColors colors, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.surfaceBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textSub,
                  letterSpacing: 0.04 * 11,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Icon(Icons.edit, size: 16, color: colors.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishOverlay(BuildContext context, AppColors colors) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 背景にうっすらと時計。
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.16,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: AnalogClock(time: _current),
                ),
              ),
            ),
          ),
          // 全面オーバーレイ。
          Positioned.fill(
            child: ColoredBox(
              color: colors.finishBg,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EXAM FINISHED',
                      style: TextStyle(
                        color: colors.finishLabel,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.34 * 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '試験終了',
                      style: TextStyle(
                        color: colors.finishTitle,
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.06 * 42,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'おつかれさまでした',
                      style: TextStyle(
                        color: colors.finishSub,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _dismissOverlay,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '元の画面に戻る',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
