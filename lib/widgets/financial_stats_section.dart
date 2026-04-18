import 'package:flutter/material.dart';
import '../view_models/cash_flow_controller.dart';
import 'summary_card.dart';

class FinancialStatsSection extends StatelessWidget {
  final CashFlowController controller;

  const FinancialStatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                progress: 0.85,
                progressText: 'Income',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: SummaryCard(
                title: 'Total Expenses',
                amount: 'Rs ${controller.monthlyExpenses.toInt()}',
                icon: Icons.trending_down_rounded,
                iconColor: Colors.redAccent,
                progress: 0.65,
                progressText: 'Expenses',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Receivables',
                amount: 'Rs ${controller.pendingReceivables.toInt()}',
                icon: Icons.call_received_rounded,
                iconColor: Colors.blue,
                progress: 0.45,
                progressText: 'Pending',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: SummaryCard(
                title: 'Payables',
                amount: 'Rs ${controller.pendingPayables.toInt()}',
                icon: Icons.call_made_rounded,
                iconColor: Colors.orange,
                progress: 0.30,
                progressText: 'Due Soon',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
