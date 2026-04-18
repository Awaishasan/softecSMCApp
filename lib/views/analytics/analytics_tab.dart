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

              // Date range chips
              AnalyticsDateFilter(ctrl: ctrl),
              const SizedBox(height: 20),

              // Income / Expense summary tiles
              AnalyticsSummaryRow(ctrl: ctrl),
              const SizedBox(height: 20),

              // Bar chart (respects date range)
              AnalyticsChartSection(ctrl: ctrl),
              const SizedBox(height: 28),

              // Header row
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

              // Type filter tabs (All / Income / Expense)
              AnalyticsFilterTabs(ctrl: ctrl),
              const SizedBox(height: 16),

              // Filtered + searched list
              AnalyticsTransactionsList(ctrl: ctrl),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
