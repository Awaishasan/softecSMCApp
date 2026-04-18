import 'package:flutter/material.dart';
import '../view_models/dashboard_controller.dart';
import 'activity_item.dart';

class TransactionsList extends StatelessWidget {
  final DashboardController controller;

  const TransactionsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final tx = controller.transactions[index];
        return ActivityItem(
          title: tx['title']!,
          subtitle: tx['subtitle']!,
          amount: tx['amount']!,
          time: tx['time']!,
          type: tx['type']!,
        );
      },
    );
  }
}
