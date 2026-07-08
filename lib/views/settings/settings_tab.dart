import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../services/pdf_export_service.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/cash_flow_controller.dart';
import '../../view_models/dashboard_controller.dart';
import '../../view_models/settings_view_model.dart';
import 'legal_screen.dart';
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
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
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

                  SettingsProfileCard(ctrl: dashCtrl),
                  const SizedBox(height: 28),

                  // ── Preferences ──────────────────────────────────────────
                  SettingsSection(
                    title: 'Preferences',
                    tiles: [
                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: Colors.indigo,
                        title: 'Dark Mode',
                        subtitle: ctrl.darkModeEnabled
                            ? 'Dark theme active'
                            : 'Light theme active',
                        trailing: Switch(
                          value: ctrl.darkModeEnabled,
                          onChanged: ctrl.toggleDarkMode,
                          activeColor: AppColors.primaryBlue,
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Notifications ─────────────────────────────────────────
                  SettingsSection(
                    title: 'Notifications',
                    tiles: [
                      SettingsTile(
                        icon: Icons.payment_rounded,
                        iconColor: Colors.green,
                        title: 'Payment Reminders',
                        subtitle: 'Alerts for pending payables',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Data & Export ─────────────────────────────────────────
                  SettingsSection(
                    title: 'Data & Export',
                    tiles: [
                      SettingsTile(
                        icon: Icons.picture_as_pdf_rounded,
                        iconColor: Colors.red,
                        title: 'Export Transactions',
                        subtitle: 'Download full history as PDF',
                        onTap: () => _exportPdf(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── About ─────────────────────────────────────────────────
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
                        iconColor: Colors.teal,
                        title: 'Privacy Policy',
                        onTap: () => Get.to(
                          () => const PrivacyPolicyScreen(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        iconColor: Colors.blueGrey,
                        title: 'Terms of Service',
                        onTap: () => Get.to(
                          () => const TermsOfServiceScreen(),
                          transition: Transition.rightToLeft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),


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
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final cashCtrl = Get.find<CashFlowController>();
    final dashCtrl = Get.find<DashboardController>();

    if (cashCtrl.allTransactions.isEmpty) {
      Get.snackbar('No Data', 'No transactions to export yet.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 12);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await PdfExportService.exportTransactions(
        transactions: cashCtrl.allTransactions,
        totalBalance: cashCtrl.totalBalance,
        totalIncome: cashCtrl.monthlySales,
        totalExpenses: cashCtrl.monthlyExpenses,
        userName: dashCtrl.getUserDisplayName(),
      );
    } catch (_) {
      Get.snackbar('Export Failed', 'Could not generate PDF. Try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 12);
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  void _showCurrencyPicker(BuildContext context, SettingsViewModel ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Currency',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue)),
            const SizedBox(height: 12),
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
