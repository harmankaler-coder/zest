import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class GoalCreationWizard extends StatefulWidget {
  const GoalCreationWizard({super.key});

  @override
  State<GoalCreationWizard> createState() => _GoalCreationWizardState();
}

class _GoalCreationWizardState extends State<GoalCreationWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Goal data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final List<TextEditingController> _whyControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  DateTime? _startDate;
  GoalCategory _category = GoalCategory.personal;
  Priority _priority = Priority.medium;
  double _targetScore = 85.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    for (var controller in _whyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _createGoal() {
    if (_titleController.text.trim().isEmpty || _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final goal = Goal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate!,
      category: _category,
      priority: _priority,
      targetScore: _targetScore,
      vision: _visionController.text.trim().isNotEmpty 
          ? _visionController.text.trim() 
          : null,
      whyReasons: _whyControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
    );

    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Goal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? const Color(0xFF667eea) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildBasicInfoPage(),
                _buildCategoryPriorityPage(),
                _buildVisionPage(),
                _buildWhyPage(),
                _buildTargetPage(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF667eea),
                          Color(0xFF764ba2),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ElevatedButton(
                      onPressed: _currentPage == 4 ? _createGoal : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(_currentPage == 4 ? 'Create Goal' : 'Next'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s start with the basics of your 12-week goal.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Goal Title *',
              hintText: 'e.g., Lose 20 pounds',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Provide more details about your goal...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          
          const SizedBox(height: 16),
          
          ListTile(
            title: const Text('Start Date *'),
            subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Select start date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _startDate = date);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPriorityPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category & Priority',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Categorize your goal and set its priority level.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GoalCategory.values.map((category) {
              final isSelected = _category == category;
              return FilterChip(
                label: Text(Goal(title: '', startDate: DateTime.now(), category: category).categoryDisplayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _category = category);
                },
                selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                checkmarkColor: const Color(0xFF667eea),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          const Text('Priority', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          
          Column(
            children: Priority.values.map((priority) {
              return RadioListTile<Priority>(
                title: Text(priority.name.toUpperCase()),
                subtitle: Text(_getPriorityDescription(priority)),
                value: priority,
                groupValue: _priority,
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
                activeColor: const Color(0xFF667eea),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Vision',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe what success looks like when you achieve this goal.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _visionController,
            decoration: const InputDecoration(
              labelText: 'Vision Statement (Optional)',
              hintText: 'I will feel confident and energetic, fitting into my favorite clothes...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            maxLength: 1000,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Vision Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Be specific and vivid\n'
                  '• Focus on how you\'ll feel\n'
                  '• Include sensory details\n'
                  '• Make it inspiring and motivating',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Why',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Why is this goal important to you? Strong reasons create unstoppable motivation.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _whyControllers[index],
                decoration: InputDecoration(
                  labelText: 'Reason ${index + 1} ${index == 0 ? "(Required)" : "(Optional)"}',
                  hintText: 'Why is this goal important to you?',
                  border: const OutlineInputBorder(),
                ),
                maxLength: 200,
              ),
            );
          }),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Why This Matters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your "why" is your fuel. When motivation fades, your reasons will keep you going. Make them personal and emotional.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Execution Target',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your target execution score. This measures how consistently you complete your weekly actions.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Target Execution Score',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${_targetScore.toInt()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
                Slider(
                  value: _targetScore,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  activeColor: const Color(0xFF667eea),
                  onChanged: (value) => setState(() => _targetScore = value),
                ),
                Text(
                  _getScoreDescription(_targetScore),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.target, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Execution Score Guide',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 85%+ = Excellent execution\n'
                  '• 70-84% = Good execution\n'
                  '• 60-69% = Fair execution\n'
                  '• Below 60% = Poor execution',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityDescription(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Critical to your success, requires immediate attention';
      case Priority.medium:
        return 'Important but not urgent, steady progress needed';
      case Priority.low:
        return 'Nice to have, work on when time permits';
    }
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Perfectionist - Very challenging but achievable';
    if (score >= 85) return 'High Achiever - Excellent execution standard';
    if (score >= 75) return 'Solid Performer - Good execution standard';
    if (score >= 65) return 'Steady Progress - Moderate execution standard';
    return 'Getting Started - Gentle execution standard';
  }
}