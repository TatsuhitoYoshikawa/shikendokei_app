import 'package:flutter/material.dart';

import '../models/exam_preset.dart';
import 'time_setting_dialog.dart';

/// プリセットを新規作成・編集するダイアログ。
/// 名称・開始時刻・終了時刻を入力し、確定で [ExamPreset] を返す。
class PresetEditDialog extends StatefulWidget {
  const PresetEditDialog({super.key, this.initial});

  /// 編集対象。null の場合は新規作成。
  final ExamPreset? initial;

  static Future<ExamPreset?> show(
    BuildContext context, {
    ExamPreset? initial,
  }) {
    return showDialog<ExamPreset>(
      context: context,
      builder: (_) => PresetEditDialog(initial: initial),
    );
  }

  @override
  State<PresetEditDialog> createState() => _PresetEditDialogState();
}

class _PresetEditDialogState extends State<PresetEditDialog> {
  late final TextEditingController _nameController;
  late Duration _start;
  late Duration _end;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initial?.name ?? '');
    _start = widget.initial?.start ?? const Duration(hours: 9, minutes: 30);
    _end = widget.initial?.end ?? const Duration(hours: 12);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = (d.inSeconds ~/ 3600) % 24;
    final m = (d.inSeconds ~/ 60) % 60;
    final s = d.inSeconds % 60;
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Future<void> _pickStart() async {
    final result = await TimeSettingDialog.show(
      context,
      title: '開始時刻を設定',
      initial: _start,
    );
    if (result != null) setState(() => _start = result);
  }

  Future<void> _pickEnd() async {
    final result = await TimeSettingDialog.show(
      context,
      title: '終了時刻を設定',
      initial: _end,
    );
    if (result != null) setState(() => _end = result);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = '名称を入力してください');
      return;
    }
    Navigator.of(context).pop(
      ExamPreset(name: name, start: _start, end: _end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'プリセットを追加' : 'プリセットを編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '名称',
              hintText: '例: 東大入試1日目1限 国語',
              errorText: _nameError,
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          _timeRow('開始時刻', _fmt(_start), _pickStart),
          const SizedBox(height: 8),
          _timeRow('終了時刻', _fmt(_end), _pickEnd),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _timeRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 18),
          ],
        ),
      ),
    );
  }
}
