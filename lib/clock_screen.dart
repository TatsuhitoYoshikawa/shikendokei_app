import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'models/exam_preset.dart';
import 'preset_store.dart';
import 'widgets/analog_clock.dart';
import 'widgets/digital_clock.dart';
import 'widgets/preset_manager_sheet.dart';
import 'widgets/time_setting_dialog.dart';

/// 試験時計のメイン画面（1画面構成）。
///
/// 設定した開始時刻を起点に、開始ボタンで1秒ずつ時を刻む。終了時刻に達すると
/// 音を鳴らし「試験終了」オーバーレイを表示する（画面遷移はしない）。
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

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
      setState(() => _endTime = result);
    }
  }

  // ---- プリセット ---------------------------------------------------------

  Future<void> _openPresets() async {
    _stop(); // 設定操作と同様、時の刻みは止める。
    final selected = await PresetManagerSheet.show(
      context,
      presets: _presets,
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
    });
  }

  // ---- UI -----------------------------------------------------------------

  String _fmt(Duration d) {
    final h = (d.inSeconds ~/ 3600) % 24;
    final m = (d.inSeconds ~/ 60) % 60;
    final s = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('試験時計'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildMain(context),
          if (_examFinished) _buildFinishOverlay(context),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // アナログ/デジタル切替
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('アナログ')),
                ButtonSegment(value: false, label: Text('デジタル')),
              ],
              selected: {_isAnalog},
              onSelectionChanged: (s) =>
                  setState(() => _isAnalog = s.first),
            ),
            const SizedBox(height: 24),

            // 時計表示
            SizedBox(
              height: 320,
              child: Center(
                child: _isAnalog
                    ? AnalogClock(time: _current)
                    : DigitalClock(time: _current),
              ),
            ),
            const SizedBox(height: 24),

            // 開始/停止ボタン
            SizedBox(
              width: 220,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isRunning ? _stop : _start,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isRunning ? '停止' : '開始',
                  style: const TextStyle(fontSize: 20),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // プリセット選択
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openPresets,
                icon: const Icon(Icons.list_alt),
                label: const Text('プリセットから選択 / 管理'),
              ),
            ),
            const SizedBox(height: 16),

            // 時刻設定
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timeSettingCard(
                  label: '開始時刻',
                  value: _fmt(_startTime),
                  onTap: _editStartTime,
                ),
                _timeSettingCard(
                  label: '終了時刻',
                  value: _fmt(_endTime),
                  onTap: _editEndTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeSettingCard({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.edit, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishOverlay(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '試験終了',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _dismissOverlay,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  '元の画面に戻る',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
