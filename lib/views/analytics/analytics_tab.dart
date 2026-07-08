import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';
import 'analytics_summary_row.dart';
import 'analytics_date_filter.dart';
import 'analytics_chart_section.dart';
import 'analytics_filter_tabs.dart';
import 'analytics_transactions_list.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashFlowController>(
      builder: (ctrl) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue),
                    ),
                    const Text(
                      'Your full transaction history',
                      style: TextStyle(fontSize: 15, color: AppColors.grayText),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Date Filters, AnalyticsSummaryRow, AnalyticsChartSection
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnalyticsDateFilter(ctrl: ctrl),
                              const SizedBox(height: 20),
                              AnalyticsSummaryRow(ctrl: ctrl),
                              const SizedBox(height: 20),
                              AnalyticsChartSection(ctrl: ctrl),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        // Right Column: Filter tabs and the actual transactions list
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Transactions',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlue),
                                  ),
                                  Text(
                                    '${ctrl.displayedTransactions.length} records',
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.grayText),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AnalyticsFilterTabs(ctrl: ctrl),
                              const SizedBox(height: 16),
                              AnalyticsTransactionsList(ctrl: ctrl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // Mobile layout (default)
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Analytics',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue),
                  ),
                  const Text(
                    'Your full transaction history',
                    style: TextStyle(fontSize: 14, color: AppColors.grayText),
                  ),
                  const SizedBox(height: 20),
                  AnalyticsDateFilter(ctrl: ctrl),
                  const SizedBox(height: 20),
                  AnalyticsSummaryRow(ctrl: ctrl),
                  const SizedBox(height: 20),
                  AnalyticsChartSection(ctrl: ctrl),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlue),
                      ),
                      Text(
                        '${ctrl.displayedTransactions.length} records',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.grayText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnalyticsFilterTabs(ctrl: ctrl),
                  const SizedBox(height: 16),
                  AnalyticsTransactionsList(ctrl: ctrl),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
