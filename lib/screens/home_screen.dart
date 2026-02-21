import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroGrip Dashboard'),
        actions: [
          IconButton(
            icon: Icon(
              appState.isTtsEnabled ? Icons.volume_up : Icons.volume_off,
              color: appState.isTtsEnabled ? Colors.green : Colors.red,
            ),
            onPressed: () => appState.toggleTts(),
            tooltip: 'Toggle TTS',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator(
                  context,
                  Icons.bluetooth,
                  'Bluetooth',
                  appState.isBluetoothOn,
                ),
                _buildStatusIndicator(
                  context,
                  Icons.wifi,
                  'Wi-Fi',
                  appState.isWifiOn,
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Live Detection Output',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Live Detection Container
                  Expanded(
                    child: ZoomIn(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Pulse(
                                infinite: true,
                                child: Icon(
                                  Icons.radar,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  appState.currentGestureText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavCard(
                          context,
                          'Gesture History',
                          Icons.history,
                          '/history',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildNavCard(
                          context,
                          'Settings',
                          Icons.settings_outlined,
                          '/settings',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Simulated Input Button
                  ElevatedButton.icon(
                    onPressed: () {
                      final gestures = ['Hello', 'Help', 'Water', 'Hungry', 'Yes', 'No'];
                      final randomGesture = (gestures..shuffle()).first;
                      appState.updateGesture(randomGesture);
                    },
                    icon: const Icon(Icons.touch_app),
                    label: const Text('Simulate Gesture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, IconData icon, String label, bool isOn) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isOn ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isOn ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOn ? '(Connected)' : '(Disconnected)',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
