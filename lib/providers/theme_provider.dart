// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _themeBoxName = 'app_theme_box';
  static const _themeKey = 'theme_preference';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      if (!Hive.isBoxOpen(_themeBoxName)) {
        await Hive.openBox(_themeBoxName);
      }
      final box = Hive.box(_themeBoxName);
      final themeIndex = box.get(_themeKey, defaultValue: ThemeMode.system.index);
      state = ThemeMode.values[themeIndex];
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        await Hive.openBox(_themeBoxName);
      }
      final box = Hive.box(_themeBoxName);
      await box.put(_themeKey, mode.index);
    } catch (_) {}
  }

  void toggleTheme() {
    final newMode = 
      state == ThemeMode.system || state == ThemeMode.light 
        ? ThemeMode.dark
        : ThemeMode.light;
    setTheme(newMode);
  }
}