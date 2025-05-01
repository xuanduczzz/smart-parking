// settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial());

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is ToggleThemeEvent) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkMode', event.isDarkMode);
      yield SettingsLoaded(
        isDarkMode: event.isDarkMode,
        isVietnamese: prefs.getBool('isVietnamese') ?? false,
      );
    }

    if (event is ToggleLanguageEvent) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isVietnamese', event.isVietnamese);
      yield SettingsLoaded(
        isDarkMode: prefs.getBool('isDarkMode') ?? false,
        isVietnamese: event.isVietnamese,
      );
    }
  }
}
