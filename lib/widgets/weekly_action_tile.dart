import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class WeeklyActionTile extends StatelessWidget {
  final WeeklyAction action;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const WeeklyActionTile({
    super.key,
    required this.action,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: action.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: Colors.green,
        ),
        title: Text(
          action.description,
          style: TextStyle(
            decoration: action.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
            color: action.isCompleted 
                ? Colors.grey 
                : null,
          ),
        ),
        subtitle: action.completedDate != null
            ? Text(
                'Completed: ${action.completedDate!.toString().split(' ')[0]}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            } else if (value == 'edit') {
              _showEditDialog(context);
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: action.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Action'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Action description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                action.description = controller.text.trim();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}