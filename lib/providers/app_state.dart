import 'package:flutter/material.dart';
import '../models/gesture_model.dart';

class AppState extends ChangeNotifier {
  // Connectivity Status
  bool _isBluetoothOn = true;
  bool _isWifiOn = true;

  bool get isBluetoothOn => _isBluetoothOn;
  bool get isWifiOn => _isWifiOn;

  void toggleBluetooth() {
    _isBluetoothOn = !_isBluetoothOn;
    notifyListeners();
  }

  void toggleWifi() {
    _isWifiOn = !_isWifiOn;
    notifyListeners();
  }

  // Personalization
  String _selectedLanguage = 'English';
  String get selectedLanguage => _selectedLanguage;

  void setLanguage(String lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  // Emergency Contact
  String _emergencyName = '';
  String _emergencyPhone = '';

  String get emergencyName => _emergencyName;
  String get emergencyPhone => _emergencyPhone;

  void updateEmergencyContact(String name, String phone) {
    _emergencyName = name;
    _emergencyPhone = phone;
    notifyListeners();
  }

  // Live Detection
  String _currentGestureText = 'Waiting for input...';
  String get currentGestureText => _currentGestureText;

  bool _isTtsEnabled = true;
  bool get isTtsEnabled => _isTtsEnabled;

  void toggleTts() {
    _isTtsEnabled = !_isTtsEnabled;
    notifyListeners();
  }

  void updateGesture(String text) {
    _currentGestureText = text;
    _addHistory(GestureModel(
      name: text,
      action: 'Detected',
      timestamp: DateTime.now(),
    ));
    if (_isTtsEnabled) {
      _ttsLog.add('Detected gesture: $text');
    }
    notifyListeners();
  }

  // History
  final List<GestureModel> _history = [];
  List<GestureModel> get history => List.unmodifiable(_history.reversed);

  void _addHistory(GestureModel item) {
    _history.add(item);
    if (_history.length > 50) _history.removeAt(0);
  }

  // Communication Log (TTS Outputs)
  final List<String> _ttsLog = [];
  List<String> get ttsLog => List.unmodifiable(_ttsLog.reversed);

  void addToTtsLog(String message) {
    _ttsLog.add(message);
    notifyListeners();
  }
}
