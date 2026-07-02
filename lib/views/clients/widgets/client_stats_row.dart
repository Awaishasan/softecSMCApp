import 'package:flutter/material.dart';
import '../../../models/client_model.dart';
import '../../../res/app_colors.dart';

class ClientStatsRow extends StatelessWidget {
  final ClientModel client;
  const ClientStatsRow({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Total Spend',
          value: 'Rs ${client.totalSpend.toStringAsFixed(0)}',
          icon: Icons.shopping_bag_outlined,
          color: Colors.green,
        ),
        const SizedBox(width: 10),
        _StatTile(
          label: 'Outstanding',
          value: 'Rs ${client.outstandingBalance > 0 ? client.outstandingBalance.toStringAsFixed(0) : '0'}',
          icon: Icons.account_balance_wallet_outlined,
          color: client.hasBalance ? Colors.orange : Colors.grey,
        ),
        const SizedBox(width: 10),
        _StatTile(
          label: 'Last Visit',
          value: client.lastVisit != null
              ? _formatDate(client.lastVisit!)
              : 'N/A',
          icon: Icons.calendar_today_outlined,
          color: AppColors.primaryBlue,
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year.toString().substring(2)}';
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.grayText)),
          ],
        ),
      ),
    );
  }
}
