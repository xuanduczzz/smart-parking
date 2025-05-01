import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Tải cài đặt đã lưu từ SharedPreferences
  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isVietnamese = prefs.getBool('isVietnamese') ?? false;
    });
  }

  // Lưu cài đặt mới vào SharedPreferences
  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
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
                setState(() {
                  isDarkMode = value;
                  _saveSettings();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Chuyển ngôn ngữ sang tiếng Việt'),
              value: isVietnamese,
              onChanged: (value) {
                setState(() {
                  isVietnamese = value;
                  _saveSettings();
                });
                if (value) {
                  // Cập nhật ngôn ngữ ứng dụng sang Tiếng Việt
                  // Bạn có thể dùng `Get` hoặc `intl` để thay đổi ngôn ngữ
                  // Để đơn giản, ở đây chỉ là phần gợi ý
                  print("Changed to Vietnamese");
                } else {
                  // Cập nhật ngôn ngữ ứng dụng sang Tiếng Anh
                  print("Changed to English");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
