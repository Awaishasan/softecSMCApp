import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';
import '../view_models/cash_flow_controller.dart';
import '../view_models/client_controller.dart';

class BalanceCard extends StatelessWidget {
  final CashFlowController controller;

  const BalanceCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(25),
        gradient: AppColors.navyGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: controller.isSummaryLoading
          ? const SizedBox(
              height: 120,
              child: Center(
                  child: CircularProgressIndicator(color: Colors.white54)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Balance',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('Live',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          SizedBox(width: 4),
                          Text('updated',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Total balance amount ──────────────────────────────
                Text(
                  'PKR ${controller.totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // ── Cash In / Cash Out ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BalanceStat(
                      label: 'Cash In',
                      value:
                          'PKR ${controller.monthlySales.toStringAsFixed(0)}',
                      color: Colors.greenAccent,
                      icon: Icons.arrow_downward_rounded,
                    ),
                    _BalanceStat(
                      label: 'Cash Out',
                      value:
                          'PKR ${controller.monthlyExpenses.toStringAsFixed(0)}',
                      color: Colors.redAccent,
                      icon: Icons.arrow_upward_rounded,
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(
                    color: Colors.white.withOpacity(0.15), height: 1),
                const SizedBox(height: 14),

                // ── Client Payments row ───────────────────────────────
                GetBuilder<ClientController>(
                  builder: (clientCtrl) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Client Payments',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'PKR ${clientCtrl.totalClientPayments.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Paid',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final CrossAxisAlignment crossAxisAlignment;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
