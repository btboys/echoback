import 'package:flutter/material.dart';

class RecordingCard extends StatelessWidget {
  final String fileName;
  final String date;
  final String duration;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;
  final bool isSelected;
  final bool showCheckbox;

  const RecordingCard({
    super.key,
    required this.fileName,
    required this.date,
    required this.duration,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
    this.isSelected = false,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      child: ListTile(
        leading: showCheckbox
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        title: Text(
          fileName,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$date${duration.isNotEmpty ? ' · $duration' : ''}'),
        trailing: showCheckbox
            ? null
            : PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'rename':
                      _showRenameDialog(context);
                    case 'delete':
                      _showDeleteDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'rename', child: Text('重命名')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: fileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onRename(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除录音'),
        content: Text('确定删除"$fileName"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
