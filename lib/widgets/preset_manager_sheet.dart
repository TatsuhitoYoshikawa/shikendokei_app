import 'package:flutter/material.dart';

import '../models/exam_preset.dart';
import '../theme/app_colors.dart';
import 'preset_edit_dialog.dart';

/// プリセットの一覧を表示し、選択・追加・編集・削除を行うボトムシート。
///
/// プリセットをタップすると、その [ExamPreset] を返して閉じる（呼び出し側で適用）。
/// 追加・編集・削除があった場合は [onChanged] で更新後の一覧を通知する
/// （呼び出し側で永続化する）。
class PresetManagerSheet extends StatefulWidget {
  const PresetManagerSheet({
    super.key,
    required this.presets,
    required this.onChanged,
    this.selectedName,
  });

  final List<ExamPreset> presets;
  final ValueChanged<List<ExamPreset>> onChanged;

  /// 現在選択中のプリセット名（チェック表示に使用）。
  final String? selectedName;

  /// シートを表示し、選択された [ExamPreset] を返す（未選択で閉じた場合は null）。
  static Future<ExamPreset?> show(
    BuildContext context, {
    required List<ExamPreset> presets,
    required ValueChanged<List<ExamPreset>> onChanged,
    String? selectedName,
  }) {
    return showModalBottomSheet<ExamPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => PresetManagerSheet(
        presets: presets,
        onChanged: onChanged,
        selectedName: selectedName,
      ),
    );
  }

  @override
  State<PresetManagerSheet> createState() => _PresetManagerSheetState();
}

class _PresetManagerSheetState extends State<PresetManagerSheet> {
  late List<ExamPreset> _presets;

  @override
  void initState() {
    super.initState();
    _presets = List.of(widget.presets);
  }

  void _commit() => widget.onChanged(List.of(_presets));

  /// 時間レンジ表示（例「09:30 – 12:00」）。秒は表示しない。
  String _range(ExamPreset p) {
    String hm(Duration d) {
      String two(int n) => n.toString().padLeft(2, '0');
      final h = (d.inSeconds ~/ 3600) % 24;
      final m = (d.inSeconds ~/ 60) % 60;
      return '${two(h)}:${two(m)}';
    }

    return '${hm(p.start)} – ${hm(p.end)}';
  }

  Future<void> _add() async {
    final created = await PresetEditDialog.show(context);
    if (created != null) {
      setState(() => _presets.add(created));
      _commit();
    }
  }

  Future<void> _edit(int index) async {
    final edited =
        await PresetEditDialog.show(context, initial: _presets[index]);
    if (edited != null) {
      setState(() => _presets[index] = edited);
      _commit();
    }
  }

  void _delete(int index) {
    setState(() => _presets.removeAt(index));
    _commit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ハンドルバー
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: colors.segBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ヘッダ行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'プリセット',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _add,
                    icon: Icon(Icons.add, color: colors.primary, size: 24),
                    tooltip: 'プリセットを追加',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (_presets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'プリセットがありません。\n「新しいプリセットを追加」から作成してください。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSub, fontSize: 13),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _presets.length,
                    itemBuilder: (context, index) =>
                        _presetRow(colors, index),
                  ),
                ),
              // 末尾行：新しいプリセットを追加
              InkWell(
                onTap: _add,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 15, bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.hairline)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '新しいプリセットを追加',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetRow(AppColors colors, int index) {
    final p = _presets[index];
    final isSelected = widget.selectedName != null && p.name == widget.selectedName;
    return InkWell(
      onTap: () => Navigator.of(context).pop(p),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.hairline)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _range(p),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textSub,
                      letterSpacing: 0.04 * 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 22)
            else
              _rowMenu(colors, index),
          ],
        ),
      ),
    );
  }

  Widget _rowMenu(AppColors colors, int index) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: colors.textMuted, size: 20),
      tooltip: 'メニュー',
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'edit') _edit(index);
        if (value == 'delete') _delete(index);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('編集')),
        PopupMenuItem(value: 'delete', child: Text('削除')),
      ],
    );
  }
}
