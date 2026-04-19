import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';
import '../view_models/dashboard_controller.dart';
import '../view_models/auth_view_model.dart';
import '../utils/dashboard_bottom_nav.dart';
import 'home_tab.dart';
import 'analytics/analytics_tab.dart';
import 'clients/clients_tab.dart';
import 'settings/settings_tab.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Get.find<AuthViewModel>();

    return GetBuilder<DashboardController>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(ctrl, authViewModel),
          body: IndexedStack(
            index: ctrl.selectedIndex,
            children: [
              HomeTab(controller: ctrl),
              const AnalyticsTab(),
              const ClientsTab(),
              const SettingsTab(),
            ],
          ),
          bottomNavigationBar: DashboardBottomNav(controller: ctrl),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      DashboardController ctrl, AuthViewModel authViewModel) {
    final onAnalytics = ctrl.selectedIndex == 1;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: ctrl.isSearchVisible
          ? TextField(
              controller: ctrl.searchTextController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name or note...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.grayText),
              ),
              style: const TextStyle(color: AppColors.textBlue),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '₹',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Mera Hisab',
                    style: TextStyle(
                        color: AppColors.textBlue,
                        fontWeight: FontWeight.bold)),
              ],
            ),
      actions: [

        if (onAnalytics || ctrl.isSearchVisible)
          IconButton(
            icon: Icon(
              ctrl.isSearchVisible ? Icons.close : Icons.search,
              color: AppColors.textBlue,
            ),
            onPressed: ctrl.toggleSearch,
          ),
        Stack(
          children: [
            IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textBlue),
                onPressed: () {}),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Text('1',
                    style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textBlue),
          onSelected: (value) {
            if (value == 'logout') authViewModel.signOut();
            if (value == 'settings') ctrl.changeTabIndex(3);
          },
          itemBuilder: (_) => [
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(children: [
                Icon(Icons.settings_outlined,
                    color: AppColors.iconBlue, size: 18),
                SizedBox(width: 8),
                Text('Settings'),
              ]),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(children: [
                Icon(Icons.logout, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
