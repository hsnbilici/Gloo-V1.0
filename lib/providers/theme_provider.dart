import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial]);
  final ThemeMode? _initial;

  @override
  ThemeMode build() => _initial ?? ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
