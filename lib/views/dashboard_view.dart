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
import 'inventory/inventory_tab.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Get.find<AuthViewModel>();

    return GetBuilder<DashboardController>(
      builder: (ctrl) {
        final content = IndexedStack(
          index: ctrl.selectedIndex,
          children: [
            HomeTab(controller: ctrl),
            const ClientsTab(),
            const InventoryTab(),
            const AnalyticsTab(),
            const SettingsTab(),
          ],
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar(ctrl, authViewModel),
              body: isDesktop
                  ? Row(
                      children: [
                        NavigationRail(
                          selectedIndex: ctrl.selectedIndex,
                          onDestinationSelected: ctrl.changeTabIndex,
                          labelType: NavigationRailLabelType.all,
                          backgroundColor: Colors.white,
                          selectedIconTheme: const IconThemeData(color: AppColors.primaryBlue),
                          selectedLabelTextStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                          unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
                          unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                          destinations: const [
                            NavigationRailDestination(
                                icon: Icon(Icons.home_rounded), label: Text('Home')),
                            NavigationRailDestination(
                                icon: Icon(Icons.bar_chart_rounded), label: Text('Analytics')),
                            NavigationRailDestination(
                                icon: Icon(Icons.inventory_2_rounded), label: Text('Inventory')),
                            NavigationRailDestination(
                                icon: Icon(Icons.people_rounded), label: Text('Clients')),
                            NavigationRailDestination(
                                icon: Icon(Icons.person_outline_rounded), label: Text('Settings')),
                          ],
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(child: content),
                      ],
                    )
                  : content,
              bottomNavigationBar: isDesktop ? null : DashboardBottomNav(controller: ctrl),
            );
          },
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
