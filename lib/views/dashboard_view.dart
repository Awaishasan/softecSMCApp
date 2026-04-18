import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard_rounded,
              size: 100,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Mera Hisab Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your financial tracking starts here.',
              style: TextStyle(color: AppColors.grayText),
            ),
          ],
        ),
      ),
    );
  }
}
