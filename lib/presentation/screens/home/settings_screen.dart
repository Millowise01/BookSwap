import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../../services/populate_books.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationReminders = false;
  bool _emailUpdates = false;
  bool _chatNotifications = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }
  
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationReminders = prefs.getBool('notification_reminders') ?? false;
      _emailUpdates = prefs.getBool('email_updates') ?? false;
      _chatNotifications = prefs.getBool('chat_notifications') ?? true;
    });
  }
  
  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${key.replaceAll('_', ' ').toUpperCase()} ${value ? 'enabled' : 'disabled'}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [

          
          const Divider(),
          
          // About Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Divider(),
          
          // Notification Settings
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.grey),
            title: const Text('Notification reminders', style: TextStyle(color: Colors.white)),
            value: _notificationReminders,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _notificationReminders = value;
              });
              _saveNotificationSetting('notification_reminders', value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email, color: Colors.grey),
            title: const Text('Email Updates', style: TextStyle(color: Colors.white)),
            value: _emailUpdates,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _emailUpdates = value;
              });
              _saveNotificationSetting('email_updates', value);
            },
          ),

        ],
      ),
    );
  }
}

