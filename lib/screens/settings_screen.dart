import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Connectivity'),
          _buildSettingTile(
            'Bluetooth',
            'Toggle Bluetooth status',
            Icons.bluetooth,
            Switch(
              value: appState.isBluetoothOn,
              onChanged: (val) => appState.toggleBluetooth(),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingTile(
            'Wi-Fi',
            'Toggle Wi-Fi status',
            Icons.wifi,
            Switch(
              value: appState.isWifiOn,
              onChanged: (val) => appState.toggleWifi(),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Personalization'),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blueAccent),
            title: const Text('Language Change'),
            subtitle: Text('Current: ${appState.selectedLanguage}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _updateLanguage(context, appState),
          ),
          ListTile(
            leading: const Icon(Icons.emergency, color: Colors.redAccent),
            title: const Text('Emergency Setup'),
            subtitle: const Text('Update contact details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _updateEmergency(context, appState),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Device Sync'),
          ListTile(
            leading: const Icon(Icons.sync, color: Colors.greenAccent),
            title: const Text('Date and Time Sync'),
            subtitle: const Text('Last synced: Just now'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synchronizing with device...')),
                );
              },
              child: const Text('Sync Now'),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Communication Log'),
          ListTile(
            leading: const Icon(Icons.message_outlined, color: Colors.orangeAccent),
            title: const Text('Previous Messages'),
            subtitle: const Text('View TTS history'),
            trailing: const Icon(Icons.history),
            onTap: () => _showTtsLog(context, appState),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, Widget trailing) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing,
      ),
    );
  }

  void _updateLanguage(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Hindi', 'Telugu'].map((lang) {
              return RadioListTile<String>(
                title: Text(lang),
                value: lang,
                groupValue: appState.selectedLanguage,
                onChanged: (val) {
                  appState.setLanguage(val!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _updateEmergency(BuildContext context, AppState appState) {
    final nameController = TextEditingController(text: appState.emergencyName);
    final phoneController = TextEditingController(text: appState.emergencyPhone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                appState.updateEmergencyContact(nameController.text, phoneController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTtsLog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.remove, color: Colors.grey)),
              const Text(
                'Communication Log',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: appState.ttsLog.isEmpty
                    ? const Center(child: Text('No messages logged yet.'))
                    : ListView.separated(
                        itemCount: appState.ttsLog.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.volume_up, size: 16),
                            title: Text(appState.ttsLog[index]),
                            subtitle: const Text('Logged'),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
