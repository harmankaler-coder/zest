import 'package:flutter/material.dart';
import '../models/goal_data.dart';
import 'package:intl/intl.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
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
            ? Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${DateFormat('MMM dd').format(action.completedDate!)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              value: 'notes',
              child: Row(
                children: [
                  Icon(Icons.note_add),
                  SizedBox(width: 8),
                  Text('Add Notes'),
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
              _showDeleteConfirmation(context);
            } else if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'notes') {
              _showNotesDialog(context);
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Action'),
        content: const Text('Are you sure you want to delete this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  action.description = controller.text.trim();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final controller = TextEditingController(text: action.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Action Notes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add notes about this action...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ElevatedButton(
              onPressed: () {
                action.notes = controller.text.trim().isNotEmpty 
                    ? controller.text.trim() 
                    : null;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}