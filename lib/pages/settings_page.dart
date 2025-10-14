import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) changeTheme;

  const SettingsPage({Key? key, required this.changeTheme}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _locationServices = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Section
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                'Username',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Current user profile',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              trailing: Icon(Icons.edit, color: Colors.green),
              onTap: () {
                // Edit profile
              },
            ),
          ),
          SizedBox(height: 16),

          // Appearance Settings
          Card(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language, color: Colors.green),
                  title: Text(
                    'Language',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    _selectedLanguage,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                    items: <String>['English', 'Chinese', 'Japanese', 'Korean']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.green,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (bool value) {
                      widget.changeTheme(
                          value ? ThemeMode.dark : ThemeMode.light
                      );
                    },
                    activeColor: Colors.green,
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.green),
                  title: Text(
                    'Push Notifications',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: _notifications,
                    onChanged: (bool value) {
                      setState(() {
                        _notifications = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text(
                    'Location Services',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: _locationServices,
                    onChanged: (bool value) {
                      setState(() {
                        _locationServices = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.green),
                  title: Text(
                    'Help & Support',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text(
                    'Privacy Center',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.green),
                  title: Text(
                    'Account Status',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Active',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Check account status
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Danger Zone
          Card(
            color: Colors.red[50],
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _showSignOutDialog();
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Account', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('This action cannot be undone. All your data will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement account deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}