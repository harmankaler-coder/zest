import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onDataCleared;

  const SettingsScreen({
    super.key, 
    this.onDataCleared,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> settings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedSettings = await StorageService.loadSettings();
    setState(() {
      settings = loadedSettings;
      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings(settings);
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      settings[key] = value;
    });
    _saveSettings();
  }

  Future<void> _clearAllData() async {
    try {
      // Clear all data
      await StorageService.saveGoals([]);
      await StorageService.saveSettings({
        'notifications_enabled': true,
        'weekly_review_day': 0,
        'has_seen_splash': true, // Keep splash as seen
      });
      
      // Update local settings
      setState(() {
        settings = {
          'notifications_enabled': true,
          'weekly_review_day': 0,
          'has_seen_splash': true,
        };
      });
      
      // Notify parent about data clearing
      if (widget.onDataCleared != null) {
        widget.onDataCleared!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All data cleared successfully'),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF111111),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // App Info Section
            _buildSection(
              'About',
              [
                _buildListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_rounded, color: Colors.white),
                  ),
                  title: '12 Week Year',
                  subtitle: 'Version 1.0.0',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),
            
            // Notifications Section
            _buildSection(
              'Notifications',
              [
                _buildSwitchTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_rounded, color: Colors.white),
                  ),
                  title: 'Enable Notifications',
                  subtitle: 'Get reminders for weekly reviews and actions',
                  value: settings['notifications_enabled'] ?? true,
                  onChanged: (value) => _updateSetting('notifications_enabled', value),
                ),
                _buildListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C88FF), Color(0xFF6C63FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: Colors.white),
                  ),
                  title: 'Weekly Review Day',
                  subtitle: _getWeekdayName(settings['weekly_review_day'] ?? 0),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showWeekdayPicker(),
                ),
              ],
            ),
            
            // Help Section
            _buildSection(
              'Help & Support',
              [
                _buildListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.help_rounded, color: Colors.white),
                  ),
                  title: 'How to Use',
                  subtitle: 'Learn about the 12 Week Year methodology',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showHelpDialog(),
                ),
                _buildListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.feedback_rounded, color: Colors.white),
                  ),
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _sendFeedback(),
                ),
              ],
            ),
            
            // Data Management Section
            _buildSection(
              'Data Management',
              [
                _buildListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                  ),
                  title: 'Clear All Data',
                  subtitle: 'Delete all goals and settings',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showClearDataDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSwitchTile({
    required Widget leading,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  String _getWeekdayName(int day) {
    const weekdays = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    return weekdays[day];
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '12 Week Year',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.flag_rounded, size: 32, color: Colors.white),
      ),
      children: [
        const Text(
          'A comprehensive goal tracking app based on the 12 Week Year methodology. '
          'Transform your life by focusing on execution over planning.',
        ),
      ],
    );
  }

  void _showWeekdayPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Review Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            return RadioListTile<int>(
              title: Text(_getWeekdayName(index)),
              value: index,
              groupValue: settings['weekly_review_day'] ?? 0,
              onChanged: (value) {
                _updateSetting('weekly_review_day', value);
                Navigator.pop(context);
              },
            );
          }),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your goals, progress, and settings. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearAllData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('12 Week Year Methodology'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The 12 Week Year is a powerful system that helps you achieve more in 12 weeks than most people do in 12 months.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Key Principles:'),
              SizedBox(height: 8),
              Text('• Focus on execution over planning'),
              Text('• Set 12-week goals instead of annual goals'),
              Text('• Plan weekly actions that move you forward'),
              Text('• Track your execution score weekly'),
              Text('• Reflect and adjust regularly'),
              Text('• Maintain accountability'),
              SizedBox(height: 16),
              Text(
                'This app helps you implement these principles with goal tracking, '
                'weekly planning, execution scoring, and reflection tools.',
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Got it', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feedback feature coming soon!'),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}