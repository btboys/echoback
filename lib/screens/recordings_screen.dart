import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/recording_provider.dart';
import '../widgets/recording_card.dart';
import '../models/recording.dart';
import '../l10n/app_localizations.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  bool _isSelecting = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordingProvider>().loadRecordings();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _isSelecting = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _toggleSelectAll(List<Recording> list) {
    setState(() {
      if (_selected.length == list.length) {
        _selected.clear();
        _isSelecting = false;
      } else {
        _selected.addAll(list.where((r) => r.id != null).map((r) => r.id!));
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除录音'),
        content: Text('确定删除选中的 $count 条录音吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final provider = context.read<RecordingProvider>();
    final items = provider.recordings.where((r) => _selected.contains(r.id)).toList();
    await provider.deleteMultiple(items);
    setState(() {
      _selected.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, _) {
        final l = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.recordList,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (provider.recordings.isNotEmpty)
                      IconButton(
                        icon: Icon(_isSelecting ? Icons.close : Icons.checklist),
                        onPressed: () => setState(() {
                          _isSelecting = !_isSelecting;
                          if (!_isSelecting) _selected.clear();
                        }),
                      ),
                    if (_isSelecting && _selected.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSelected(),
                      ),
                  ],
                ),
              ),
              if (_isSelecting)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextButton.icon(
                    icon: Icon(
                      _selected.length == provider.recordings.length
                          ? Icons.deselect
                          : Icons.select_all,
                      size: 18,
                    ),
                    label: Text(
                      _selected.length == provider.recordings.length
                          ? '取消全选'
                          : '全选',
                    ),
                    onPressed: () => _toggleSelectAll(provider.recordings),
                  ),
                ),
              const SizedBox(height: 8),
              if (provider.recordings.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_none, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          l.noRecordings,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.noRecordingsHint,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.recordings.length,
                    itemBuilder: (context, index) {
                      final recording = provider.recordings[index];
                      final dateStr = DateFormat('MM/dd HH:mm')
                          .format(recording.createdAt);
                      final durStr = recording.durationMs > 0
                          ? '${(recording.durationMs / 1000).toStringAsFixed(1)}s'
                          : '';
                      final isSelected =
                          recording.id != null && _selected.contains(recording.id);
                      return RecordingCard(
                        fileName: recording.fileName,
                        date: dateStr,
                        duration: durStr,
                        isSelected: isSelected,
                        showCheckbox: _isSelecting,
                        onTap: _isSelecting
                            ? () {
                                if (recording.id != null) {
                                  _toggleSelect(recording.id!);
                                }
                              }
                            : () {
                                Navigator.pushNamed(context, '/playback',
                                    arguments: recording);
                              },
                        onDelete: () =>
                            provider.deleteRecording(recording),
                        onRename: (newName) =>
                            provider.renameRecording(recording, newName),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
