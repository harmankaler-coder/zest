import 'package:flutter/material.dart';

import '../goal_data.dart';

class GoalEditScreen extends StatefulWidget {
  final Goal? existingGoal;

  const GoalEditScreen({super.key, this.existingGoal});

  @override
  GoalEditScreenState createState() => GoalEditScreenState();
}

class GoalEditScreenState extends State<GoalEditScreen> {
  late TextEditingController titleController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.existingGoal?.title ?? '');
    selectedDate = widget.existingGoal?.startDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.indigo.shade900,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void saveGoal() {
    final title = titleController.text.trim();
    if (title.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter title and start date'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.indigo.shade400,
        ),
      );
      return;
    }
    final newGoal = Goal(title: title, startDate: selectedDate!);
    Navigator.of(context).pop(newGoal);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.indigo.shade50, Colors.indigo.shade200],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(isEditing ? 'Edit Goal' : 'Add Goal'),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.flag, color: Colors.indigo.shade700),
              ),
              maxLength: 50,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.indigo),
                SizedBox(width: 16),
                Text(
                  selectedDate == null
                      ? 'Select Start Date'
                      : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade900),
                ),
                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.indigo.shade300,
                  ),
                  onPressed: pickDate,
                  child: Text(
                    'Pick Date',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.save, size: 26,color: Colors.white,),
              label: Text(
                'Save Goal',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.indigo.shade300,
              ),
              onPressed: saveGoal,
            ),
          ],
        ),
      ),
    );
  }
}