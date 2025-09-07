import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: Icon(Icons.view_list),
            title: Text('Card Display'),
            subtitle: Text('Grid view'),
            onTap: () {},
          ),
          _buildSectionHeader('Security'),
          ListTile(
            leading: Icon(Icons.fingerprint),
            title: Text('Biometric Lock'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          _buildSectionHeader('About'),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('0.0.1'),
          ),
        ],
      ),
    );
  }
}
