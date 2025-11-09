import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';


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
          // Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    userProfile?.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile?.name ?? 'User',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.email ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Profile Information
          ListTile(
            leading: const Icon(Icons.person, color: Colors.grey),
            title: const Text('Name', style: TextStyle(color: Colors.white)),
            subtitle: Text(userProfile?.name ?? 'Loading...', style: const TextStyle(color: Colors.grey)),
            trailing: userProfile?.name != null ? const Icon(Icons.verified, color: Colors.green) : null,
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.grey),
            title: const Text('Email', style: TextStyle(color: Colors.white)),
            subtitle: Text(userProfile?.email ?? 'Loading...', style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.school, color: Colors.grey),
            title: const Text('University', style: TextStyle(color: Colors.white)),
            subtitle: Text(userProfile?.university ?? 'Not set', style: const TextStyle(color: Colors.grey)),
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
          
          const Divider(),
          
          // Log Out Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

