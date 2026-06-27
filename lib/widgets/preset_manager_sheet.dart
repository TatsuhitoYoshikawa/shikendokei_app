import 'package:flutter/material.dart';

import '../models/exam_preset.dart';
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
  });

  final List<ExamPreset> presets;
  final ValueChanged<List<ExamPreset>> onChanged;

  /// シートを表示し、選択された [ExamPreset] を返す（未選択で閉じた場合は null）。
  static Future<ExamPreset?> show(
    BuildContext context, {
    required List<ExamPreset> presets,
    required ValueChanged<List<ExamPreset>> onChanged,
  }) {
    return showModalBottomSheet<ExamPreset>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PresetManagerSheet(presets: presets, onChanged: onChanged),
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

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = (d.inSeconds ~/ 3600) % 24;
    final m = (d.inSeconds ~/ 60) % 60;
    final s = d.inSeconds % 60;
    return '${two(h)}:${two(m)}:${two(s)}';
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'プリセットを選択',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (_presets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Text('プリセットがありません。「追加」から作成してください。'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _presets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _presets[index];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        '開始 ${_fmt(p.start)}  /  終了 ${_fmt(p.end)}',
                      ),
                      onTap: () => Navigator.of(context).pop(p),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: '編集',
                            onPressed: () => _edit(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: '削除',
                            onPressed: () => _delete(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('プリセットを追加'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
