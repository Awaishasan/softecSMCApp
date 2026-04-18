import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/dashboard_controller.dart';
import '../../view_models/settings_view_model.dart';
import 'settings_profile_card.dart';
import 'settings_section.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final authCtrl = Get.find<AuthViewModel>();

    return GetBuilder<SettingsViewModel>(
      builder: (ctrl) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Settings',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlue)),
              const SizedBox(height: 20),

              // Profile card
              SettingsProfileCard(ctrl: dashCtrl),
              const SizedBox(height: 28),

              // ── Preferences ──────────────────────────────────────────────
              SettingsSection(
                title: 'Preferences',
                tiles: [
                  SettingsTile(
                    icon: Icons.currency_exchange_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Currency',
                    subtitle: ctrl.selectedCurrency,
                    onTap: () => _showCurrencyPicker(context, ctrl),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ctrl.selectedCurrency,
                            style: const TextStyle(
                                color: AppColors.grayText, fontSize: 13)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.grayText, size: 20),
                      ],
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.indigo,
                    title: 'Dark Mode',
                    subtitle: 'Coming soon',
                    trailing: Switch(
                      value: ctrl.darkModeEnabled,
                      onChanged: ctrl.toggleDarkMode,
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Notifications ─────────────────────────────────────────────
              SettingsSection(
                title: 'Notifications',
                tiles: [
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.orange,
                    title: 'Push Notifications',
                    subtitle: 'Transaction alerts & reminders',
                    trailing: Switch(
                      value: ctrl.notificationsEnabled,
                      onChanged: ctrl.toggleNotifications,
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.payment_rounded,
                    iconColor: Colors.green,
                    title: 'Payment Reminders',
                    subtitle: 'Get reminded about pending payables',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Security ──────────────────────────────────────────────────
              SettingsSection(
                title: 'Security',
                tiles: [
                  SettingsTile(
                    icon: Icons.fingerprint_rounded,
                    iconColor: Colors.teal,
                    title: 'Biometric Lock',
                    subtitle: 'Use fingerprint to unlock',
                    trailing: Switch(
                      value: ctrl.biometricEnabled,
                      onChanged: ctrl.toggleBiometric,
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.devices_rounded,
                    iconColor: Colors.blueGrey,
                    title: 'Active Sessions',
                    subtitle: 'Manage logged-in devices',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Data & Export ─────────────────────────────────────────────
              SettingsSection(
                title: 'Data & Export',
                tiles: [
                  SettingsTile(
                    icon: Icons.download_rounded,
                    iconColor: Colors.blue,
                    title: 'Export Transactions',
                    subtitle: 'Download as CSV or PDF',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.backup_rounded,
                    iconColor: Colors.purple,
                    title: 'Backup Data',
                    subtitle: 'Sync to cloud',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── About ─────────────────────────────────────────────────────
              SettingsSection(
                title: 'About',
                tiles: [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    trailing: const SizedBox.shrink(),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.grey,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    iconColor: Colors.grey,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Logout ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: authCtrl.signOut,
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Log Out',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsViewModel ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Currency',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue)),
            const SizedBox(height: 16),
            ...SettingsViewModel.currencies.map((c) => ListTile(
                  title: Text(c,
                      style: const TextStyle(color: AppColors.textBlue)),
                  trailing: ctrl.selectedCurrency == c
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    ctrl.setCurrency(c);
                    Get.back();
                  },
                )),
          ],
        ),
      ),
    );
  }
}
