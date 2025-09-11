import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/background_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundLogo(
        child: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(16),  
        children: [
          _buildSectionHeader('Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme Color'),
                subtitle: Text(themeProvider.themeName),
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
              );
            },
          ),
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Made with Love by'),
            subtitle: Text('Kati & Marko'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('0.0.1'),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
