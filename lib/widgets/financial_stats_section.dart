import 'package:flutter/material.dart';
import '../view_models/cash_flow_controller.dart';
import 'summary_card.dart';

class FinancialStatsSection extends StatelessWidget {
  final CashFlowController controller;

  const FinancialStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final double spacing = isSmallScreen ? 8.0 : 15.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Sales',
                amount: 'Rs ${controller.monthlySales.toInt()}',
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
                progress: controller.salesProgress,
                progressText: 'Income',
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: SummaryCard(
                title: 'Total Expenses',
                amount: 'Rs ${controller.monthlyExpenses.toInt()}',
                icon: Icons.trending_down_rounded,
                iconColor: Colors.redAccent,
                progress: controller.expensesProgress,
                progressText: 'Expenses',
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Receivables',
                amount: 'Rs ${controller.pendingReceivables.toInt()}',
                icon: Icons.call_received_rounded,
                iconColor: Colors.blue,
                progress: controller.receivablesProgress,
                progressText: 'Pending',
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: SummaryCard(
                title: 'Payables',
                amount: 'Rs ${controller.pendingPayables.toInt()}',
                icon: Icons.call_made_rounded,
                iconColor: Colors.orange,
                progress: controller.payablesProgress,
                progressText: 'Due Soon',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
