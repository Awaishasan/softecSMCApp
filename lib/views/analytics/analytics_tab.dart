import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/client_controller.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (clientCtrl) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Analytics',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlue)),
              const Text('Sales performance overview',
                  style: TextStyle(fontSize: 14, color: AppColors.grayText)),
              const SizedBox(height: 24),

              // ── Summary Chips ──────────────────────────────────────
              _buildSummaryRow(clientCtrl),
              const SizedBox(height: 28),

              // ── Monthly Revenue Chart ──────────────────────────────
              _SectionTitle(
                  title: 'Monthly Revenue', icon: Icons.bar_chart_rounded),
              const SizedBox(height: 12),
              _MonthlyRevenueChart(data: clientCtrl.monthlyRevenueChart),
              const SizedBox(height: 28),

              // ── Top Customers ──────────────────────────────────────
              _SectionTitle(title: 'Top Customers', icon: Icons.star_rounded),
              const SizedBox(height: 12),
              _TopCustomersList(clients: clientCtrl.topClients),
              const SizedBox(height: 28),

              // ── Top Items Sold ─────────────────────────────────────
              _SectionTitle(
                  title: 'Top Items Sold', icon: Icons.inventory_2_rounded),
              const SizedBox(height: 12),
              _TopItemsList(items: clientCtrl.topItemsSold),
              const SizedBox(height: 28),

              // ── Outstanding Balances ───────────────────────────────
              _SectionTitle(title: 'Outstanding Balances',
                  icon: Icons.account_balance_wallet_rounded),
              const SizedBox(height: 12),
              _OutstandingList(clients: clientCtrl.defaulters),
              const SizedBox(height: 40),
            ],
          ),
        );
      }  );
      }


  }

  Widget _buildSummaryRow(ClientController ctrl) {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Total Sales',
            value: 'Rs ${ctrl.allSales.fold(0.0, (s, sale) => s + ((sale['totalAmount'] as num?)?.toDouble() ?? 0)).toStringAsFixed(0)}',
            color: Colors.green,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Outstanding',
            value: 'Rs ${ctrl.totalOutstandingBalance.toStringAsFixed(0)}',
            color: Colors.orange,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Clients',
            value: '${ctrl.allClients.length}',
            color: Colors.blue,
            icon: Icons.people_rounded,
          ),
        ),
      ],
    );
  }


// ─────────────────────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Chip
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.grayText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly Revenue Bar Chart (pure canvas, no extra packages)
// ─────────────────────────────────────────────────────────────────────────────

class _MonthlyRevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _MonthlyRevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyState(message: 'No sales data yet');
    }

    final maxRevenue = data
        .map((d) => (d['revenue'] as double))
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final revenue = d['revenue'] as double;
                final month = d['month'] as DateTime;
                final ratio = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
                final isCurrentMonth = month.month == DateTime.now().month &&
                    month.year == DateTime.now().year;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (revenue > 0)
                          Text(
                            'Rs ${_shortNum(revenue)}',
                            style: TextStyle(
                              fontSize: 8,
                              color: isCurrentMonth
                                  ? AppColors.primaryBlue
                                  : AppColors.grayText,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: (120 * ratio).clamp(4.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: isCurrentMonth
                                ? AppColors.navyGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue.withValues(alpha: 0.4),
                                      AppColors.primaryBlue.withValues(alpha: 0.2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _monthAbbr(month.month),
                          style: TextStyle(
                            fontSize: 10,
                            color: isCurrentMonth
                                ? AppColors.primaryBlue
                                : AppColors.grayText,
                            fontWeight: isCurrentMonth
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const abbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return abbr[m];
  }

  String _shortNum(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Customers
// ─────────────────────────────────────────────────────────────────────────────

class _TopCustomersList extends StatelessWidget {
  final List clients;
  const _TopCustomersList({required this.clients});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const _EmptyState(message: 'No client data yet');
    }
    return Column(
      children: List.generate(clients.length, (i) {
        final c = clients[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: i == 0 ? AppColors.navyGradient : null,
                  color: i != 0 ? AppColors.primaryBlue.withValues(alpha: 0.12) : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              i == 0 ? Colors.white : AppColors.primaryBlue,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue,
                            fontSize: 14)),
                    Text(c.phone,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grayText)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${c.totalSpend.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontSize: 13),
                  ),
                  Text('Total Spend',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.grayText)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Items Sold
// ─────────────────────────────────────────────────────────────────────────────

class _TopItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _TopItemsList({required this.items});

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(message: 'No product sales yet');
    }
    final maxQty =
        items.map((i) => i['qty'] as int).reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final qty = item['qty'] as int;
        final revenue = item['revenue'] as double;
        final ratio = maxQty > 0 ? qty / maxQty : 0.0;
        final color = _colors[i % _colors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Text('$qty units',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13)),
                  const SizedBox(width: 10),
                  Text('Rs ${revenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outstanding Balances List
// ─────────────────────────────────────────────────────────────────────────────

class _OutstandingList extends StatelessWidget {
  final List clients;
  const _OutstandingList({required this.clients});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const _EmptyState(message: 'No outstanding balances 🎉', isSuccess: true);
    }
    return Column(
      children: clients.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: Colors.orange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue,
                            fontSize: 14)),
                    Text(c.phone,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grayText)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs ${c.outstandingBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 13),
                  ),
                  const Text('Outstanding',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.grayText)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final bool isSuccess;
  const _EmptyState({required this.message, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.hourglass_empty_rounded,
            color: isSuccess ? Colors.green : AppColors.grayText,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AppColors.grayText, fontSize: 13)),
        ],
      ),
    );
  }
}
