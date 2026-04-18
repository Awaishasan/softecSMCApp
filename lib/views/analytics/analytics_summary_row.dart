import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';

class AnalyticsSummaryRow extends StatelessWidget {
  final CashFlowController ctrl;
  const AnalyticsSummaryRow({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          label: 'Total Income',
          amount: ctrl.monthlySales,
          color: Colors.green,
          icon: Icons.arrow_downward_rounded,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Total Expenses',
          amount: ctrl.monthlyExpenses,
          color: Colors.redAccent,
          icon: Icons.arrow_upward_rounded,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grayText)),
                  const SizedBox(height: 2),
                  Text(
                    'Rs ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
