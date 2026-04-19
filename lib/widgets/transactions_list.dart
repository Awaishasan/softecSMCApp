import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../res/app_colors.dart';
import '../view_models/cash_flow_controller.dart';
import 'activity_item.dart';

class TransactionsList extends StatelessWidget {
  final CashFlowController controller;

  const TransactionsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No transactions yet.\nUse Send, Receive or Add Money to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grayText),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final tx = controller.transactions[index];
        return ActivityItem(
          transactionId: tx.id,
          title: tx.title,
          subtitle: tx.subtitle,
          amount: tx.formattedAmount,
          time: tx.timeAgo,
          type: tx.type == TransactionType.income ? 'income' : 'expense',
          onDelete: () => controller.deleteTransaction(tx.id),
        );
      },
    );
  }
}
