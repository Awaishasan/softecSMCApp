import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import '../view_models/dashboard_controller.dart';

class DashboardBottomNav extends StatelessWidget {
  final DashboardController controller;

  const DashboardBottomNav({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: controller.selectedIndex,
        onTap: controller.changeTabIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Clients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
