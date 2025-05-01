// settings_event.dart
part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class ToggleThemeEvent extends SettingsEvent {
  final bool isDarkMode;
  ToggleThemeEvent(this.isDarkMode);
}

class ToggleLanguageEvent extends SettingsEvent {
  final bool isVietnamese;
  ToggleLanguageEvent(this.isVietnamese);
}
