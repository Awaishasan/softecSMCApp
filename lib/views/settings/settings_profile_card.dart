import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../view_models/dashboard_controller.dart';

class SettingsProfileCard extends StatelessWidget {
  final DashboardController ctrl;
  const SettingsProfileCard({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final name = ctrl.getUserDisplayName();
    final email = ctrl.getUserEmail() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.white70, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
