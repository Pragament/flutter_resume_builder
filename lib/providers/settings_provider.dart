import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier()
      : super(Settings(
            quality: 80.0,
            selectedOption: CompressionOption.quality)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final maxFileSize = prefs.getDouble('maxFileSize');
    final quality = prefs.getDouble('quality') ?? 80.0;

    state = state.copyWith(
      maxFileSize: maxFileSize,
      quality: quality,
      selectedOption: CompressionOption.quality,
    );
  }

  void updateSelectedOption(CompressionOption value) async {
    state = state.copyWith(selectedOption: value);
  }

  Future<void> updateMaxFileSize(double? value) async {
    state = Settings(
      maxFileSize: value,
      quality: state.quality,
      selectedOption: state.selectedOption,
    );
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('maxFileSize');
    } else {
      await prefs.setDouble('maxFileSize', value);
    }
  }

  Future<void> updateQuality(double value) async {
    state = state.copyWith(quality: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quality', value);
  }
}
