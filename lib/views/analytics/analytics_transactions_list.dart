import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';
import '../../widgets/activity_item.dart';

class AnalyticsTransactionsList extends StatelessWidget {
  final CashFlowController ctrl;
  const AnalyticsTransactionsList({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final list = ctrl.displayedTransactions;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                ctrl.searchQuery.isNotEmpty
                    ? 'No results for "${ctrl.searchQuery}"'
                    : 'No transactions in this period.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grayText),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tx = list[index];
        return ActivityItem(
          transactionId: tx.id,
          title: tx.title,
          subtitle: tx.subtitle,
          amount: tx.formattedAmount,
          time: tx.timeAgo,
          type: tx.type == TransactionType.income ? 'income' : 'expense',
          onDelete: () => ctrl.deleteTransaction(tx.id),
        );
      },
    );
  }
}
