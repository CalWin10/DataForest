import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _locationServices = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text('Username'),
              subtitle: Text('Current user profile'),
              trailing: Icon(Icons.edit),
              onTap: () {
                // Edit profile
              },
            ),
          ),
          SizedBox(height: 16),
          // Settings Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language, color: Colors.green),
                  title: Text('Language'),
                  subtitle: Text(_selectedLanguage),
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.green),
                  title: Text('Push Notifications'),
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
                  title: Text('Location Services'),
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
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text('Privacy Center'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to privacy
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.green),
                  title: Text('Account Status'),
                  subtitle: Text('Active'),
                  trailing: Icon(Icons.arrow_forward_ios),
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
                  title: Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _showSignOutDialog();
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Account',
                      style: TextStyle(color: Colors.red)),
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