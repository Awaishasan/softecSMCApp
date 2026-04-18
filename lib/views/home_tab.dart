import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import '../view_models/dashboard_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/financial_stats_section.dart';
import '../widgets/transactions_list.dart';

class HomeTab extends StatelessWidget {
  final DashboardController controller;

  const HomeTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Good morning, ${controller.getUserDisplayName()}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue),
          ),
          const Text(
            'Here\'s your financial overview',
            style: TextStyle(fontSize: 14, color: AppColors.grayText),
          ),
          const SizedBox(height: 25),
          BalanceCard(controller: controller),
          const SizedBox(height: 30),
          const QuickActionsRow(),
          const SizedBox(height: 35),
          const Text(
            'Financial Overview',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue),
          ),
          const SizedBox(height: 20),
          FinancialStatsSection(controller: controller),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TransactionsList(controller: controller),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
