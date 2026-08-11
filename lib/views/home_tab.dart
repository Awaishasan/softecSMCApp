import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';
import '../view_models/dashboard_controller.dart';
import '../view_models/client_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/financial_stats_section.dart';
import '../widgets/inventory_summary_card.dart';

class HomeTab extends StatelessWidget {
  final DashboardController controller;

  const HomeTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (clientCtrl) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, ${controller.getUserDisplayName()}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue),
                    ),
                    const Text(
                      'Here\'s your business overview',
                      style: TextStyle(fontSize: 15, color: AppColors.grayText),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BalanceCard(controller: clientCtrl),
                              const SizedBox(height: 24),
                              const InventorySummaryCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sales Overview',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlue),
                              ),
                              const SizedBox(height: 16),
                              FinancialStatsSection(controller: clientCtrl),
                              const SizedBox(height: 24),
                              _buildTopClientsSection(clientCtrl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // Mobile layout
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
                    'Here\'s your business overview',
                    style: TextStyle(fontSize: 14, color: AppColors.grayText),
                  ),
                  const SizedBox(height: 25),
                  BalanceCard(controller: clientCtrl),
                  const SizedBox(height: 30),
                  const InventorySummaryCard(),
                  const SizedBox(height: 30),
                  const Text(
                    'Sales Overview',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue),
                  ),
                  const SizedBox(height: 16),
                  FinancialStatsSection(controller: clientCtrl),
                  const SizedBox(height: 30),
                  _buildTopClientsSection(clientCtrl),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopClientsSection(ClientController ctrl) {
    final topClients = ctrl.topClients;
    if (topClients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Top Clients',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topClients.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    'Rs ${c.totalSpend.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontSize: 13),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
