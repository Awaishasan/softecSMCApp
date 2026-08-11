import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';
import '../view_models/client_controller.dart';
import 'summary_card.dart';

class FinancialStatsSection extends StatelessWidget {
  // kept for API compatibility
  final dynamic controller;

  const FinancialStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (clientCtrl) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final double spacing = isSmallScreen ? 8.0 : 15.0;

        // Compute progress ratios (capped at 1.0)
        final totalRevenue = clientCtrl.allSales
            .fold(0.0, (s, sale) => s + ((sale['totalAmount'] as num?)?.toDouble() ?? 0));

        final salesProgress = totalRevenue > 0
            ? (clientCtrl.monthlySalesRevenue / totalRevenue).clamp(0.0, 1.0)
            : 0.0;
        final outstandingProgress = totalRevenue > 0
            ? (clientCtrl.totalOutstandingBalance / totalRevenue).clamp(0.0, 1.0)
            : 0.0;
        final customersProgress = clientCtrl.allClients.isNotEmpty
            ? (clientCtrl.monthlyCustomerCount / clientCtrl.allClients.length).clamp(0.0, 1.0)
            : 0.0;
        final itemsProgress = clientCtrl.monthlyItemsSold > 0 ? 1.0 : 0.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Monthly Sales',
                    amount: 'Rs ${clientCtrl.monthlySalesRevenue.toInt()}',
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.green,
                    progress: salesProgress,
                    progressText: 'This Month',
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SummaryCard(
                    title: 'Outstanding',
                    amount: 'Rs ${clientCtrl.totalOutstandingBalance.toInt()}',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.orange,
                    progress: outstandingProgress,
                    progressText: 'Pending',
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Customers/Mo',
                    amount: '${clientCtrl.monthlyCustomerCount}',
                    icon: Icons.people_rounded,
                    iconColor: Colors.blue,
                    progress: customersProgress,
                    progressText: 'Active',
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SummaryCard(
                    title: 'Items Sold/Mo',
                    amount: '${clientCtrl.monthlyItemsSold}',
                    icon: Icons.shopping_bag_rounded,
                    iconColor: Colors.purple,
                    progress: itemsProgress,
                    progressText: 'Units',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
