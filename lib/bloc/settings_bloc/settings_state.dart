// settings_state.dart
part of 'settings_bloc.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  final bool isVietnamese;

  SettingsLoaded({required this.isDarkMode, required this.isVietnamese});
}
