import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noteleaf/viewmodels/theme_viewmodel.dart' as theme_vm;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _showInspirationalQuotes = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showInspirationalQuotes = prefs.getBool('show_inspirational_quotes') ?? true;
    });
  }

  Future<void> _toggleInspirationalQuotes(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_inspirational_quotes', value);
    setState(() {
      _showInspirationalQuotes = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Consumer<theme_vm.ThemeViewModel>(
                    builder: (context, themeViewModel, child) {
                      return Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text('Light Theme'),
                            value: ThemeMode.light,
                            groupValue: themeViewModel.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                themeViewModel.setThemeMode(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Dark Theme'),
                            value: ThemeMode.dark,
                            groupValue: themeViewModel.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                themeViewModel.setThemeMode(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('System Default'),
                            value: ThemeMode.system,
                            groupValue: themeViewModel.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                themeViewModel.setThemeMode(value);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Inspirational Quotes'),
                    subtitle: const Text('Display writing quotes on app startup'),
                    value: _showInspirationalQuotes,
                    onChanged: _toggleInspirationalQuotes,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Created by'),
                    subtitle: const Text('Sleepy 😴'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Description'),
                    subtitle: const Text('A creative sanctuary for novel writers'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

