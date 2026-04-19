import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsViewModel extends GetxController {

  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedCurrency = 'PKR (₨)';

  static const currencies = [
    'PKR (₨)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'INR (₹)',
  ];

  void toggleNotifications(bool val) {
    notificationsEnabled = val;
    update();
  }

  void toggleDarkMode(bool val) {
    darkModeEnabled = val;
    // Actually switch the app theme
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  void setCurrency(String val) {
    selectedCurrency = val;
    update();
  }
}
