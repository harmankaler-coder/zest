import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final VoidCallback? onDataCleared;

  const SettingsScreen({
    super.key, 
    this.onThemeChanged,
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
    
    // Handle theme changes
    if (key == 'theme_mode' && widget.onThemeChanged != null) {
      ThemeMode themeMode;
      switch (value) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }
      widget.onThemeChanged!(themeMode);
    }
  }

  Future<void> _clearAllData() async {
    try {
      // Clear all data
      await StorageService.saveGoals([]);
      await StorageService.saveSettings({
        'notifications_enabled': true,
        'weekly_review_day': 0,
        'theme_mode': 'system',
        'has_seen_splash': true, // Keep splash as seen
      });
      
      // Update local settings
      setState(() {
        settings = {
          'notifications_enabled': true,
          'weekly_review_day': 0,
          'theme_mode': 'system',
          'has_seen_splash': true,
        };
      });
      
      // Notify parent about data clearing
      if (widget.onDataCleared != null) {
        widget.onDataCleared!();
      }
      
      // Reset theme to system default
      if (widget.onThemeChanged != null) {
        widget.onThemeChanged!(ThemeMode.system);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          _buildSection(
            'About',
            [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('12 Week Year'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          
          // Notifications Section
          _buildSection(
            'Notifications',
            [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get reminders for weekly reviews and actions'),
                value: settings['notifications_enabled'] ?? true,
                onChanged: (value) => _updateSetting('notifications_enabled', value),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Weekly Review Day'),
                subtitle: Text(_getWeekdayName(settings['weekly_review_day'] ?? 0)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showWeekdayPicker(),
              ),
            ],
          ),
          
          // Appearance Section
          _buildSection(
            'Appearance',
            [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(_getThemeName(settings['theme_mode'] ?? 'system')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(),
              ),
            ],
          ),
          
          // Help Section
          _buildSection(
            'Help & Support',
            [
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('How to Use'),
                subtitle: const Text('Learn about the 12 Week Year methodology'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHelpDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Send Feedback'),
                subtitle: const Text('Help us improve the app'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _sendFeedback(),
              ),
            ],
          ),
          
          // Data Management Section
          _buildSection(
            'Data Management',
            [
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Delete all goals and settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearDataDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getWeekdayName(int day) {
    const weekdays = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday'
    ];
    return weekdays[day];
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System Default';
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '12 Week Year',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.flag, size: 48),
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

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: 'light',
              groupValue: settings['theme_mode'] ?? 'system',
              onChanged: (value) {
                _updateSetting('theme_mode', value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: 'dark',
              groupValue: settings['theme_mode'] ?? 'system',
              onChanged: (value) {
                _updateSetting('theme_mode', value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System Default'),
              subtitle: const Text('Follow system theme'),
              value: 'system',
              groupValue: settings['theme_mode'] ?? 'system',
              onChanged: (value) {
                _updateSetting('theme_mode', value);
                Navigator.pop(context);
              },
            ),
          ],
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
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: const Text('Clear Data', style: TextStyle(color: Colors.red)),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}