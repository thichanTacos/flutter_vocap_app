import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool soundEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.soundEnabled = true,
  });

  bool get isDark => themeMode == ThemeMode.dark;

  AppSettings copyWith({ThemeMode? themeMode, bool? soundEnabled}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _kDark = 'pref_dark_mode';
  static const _kSound = 'pref_sound_enabled';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      themeMode:
          (prefs.getBool(_kDark) ?? false) ? ThemeMode.dark : ThemeMode.light,
      soundEnabled: prefs.getBool(_kSound) ?? true,
    );
  }

  Future<void> toggleTheme() async {
    final current = state.valueOrNull ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    final nowDark = !current.isDark;
    await prefs.setBool(_kDark, nowDark);
    state = AsyncData(current.copyWith(
      themeMode: nowDark ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  Future<void> toggleSound() async {
    final current = state.valueOrNull ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, !current.soundEnabled);
    state = AsyncData(current.copyWith(soundEnabled: !current.soundEnabled));
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
