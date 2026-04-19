import 'package:get/get.dart';

class SettingsViewModel extends GetxController {

  bool notificationsEnabled = true;
  bool biometricEnabled = false;
  bool darkModeEnabled = false;
  String selectedCurrency = 'USD (\$)';

  static const currencies = [
    'USD (\$)',
    'PKR (₨)',
    'EUR (€)',
    'GBP (£)',
    'INR (₹)',
  ];

  void toggleNotifications(bool val) {
    notificationsEnabled = val;
    update();
  }

  void toggleBiometric(bool val) {
    biometricEnabled = val;
    update();
  }

  void toggleDarkMode(bool val) {
    darkModeEnabled = val;
    update();
  }

  void setCurrency(String val) {
    selectedCurrency = val;
    update();
  }
}
