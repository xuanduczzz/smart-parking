import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:park/controller/theme_controller.dart'; // 💡 thêm import

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool isVietnamese = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isVietnamese = prefs.getBool('isVietnamese') ?? false;
    });
  }

  _saveLanguageSetting() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isVietnamese', isVietnamese);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Chế độ tối'),
              value: isDarkMode,
              onChanged: (value) {
                setState(() => isDarkMode = value);
                ThemeController.toggleTheme(value); // 💡 cập nhật ngay theme toàn app
              },
            ),
            SwitchListTile(
              title: const Text('Chuyển ngôn ngữ sang tiếng Việt'),
              value: isVietnamese,
              onChanged: (value) {
                setState(() => isVietnamese = value);
                _saveLanguageSetting();
                // TODO: thêm logic thay đổi ngôn ngữ nếu cần
              },
            ),
          ],
        ),
      ),
    );
  }
}
