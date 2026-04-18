import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';

class AnalyticsChartSection extends StatelessWidget {
  final CashFlowController ctrl;
  const AnalyticsChartSection({super.key, required this.ctrl});

  String get _chartTitle {
    switch (ctrl.dateFilter) {
      case DateRangeFilter.last7:
        return 'Last 7 Days';
      case DateRangeFilter.last30:
        return 'Last 30 Days';
      case DateRangeFilter.custom:
        final f = ctrl.customFrom;
        final t = ctrl.customTo;
        if (f != null && t != null) {
          return '${f.day}/${f.month} – ${t.day}/${t.month}';
        }
        return 'Custom Range';
    }
  }

  @override
  Widget build(BuildContext context) {
    final buckets = ctrl.chartBuckets;
    if (buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final allValues = buckets.expand((b) => [b.income, b.expense]);
    final maxY = allValues.fold(0.0, (a, b) => a > b ? a : b);

    // For 30-day view show every 5th label to avoid crowding
    final showEvery = buckets.length > 10 ? 5 : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _chartTitle,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue),
              ),
              Row(
                children: [
                  _Legend(color: Colors.green, label: 'In'),
                  const SizedBox(width: 12),
                  _Legend(color: Colors.redAccent, label: 'Out'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 100 : maxY * 1.3,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryBlue,
                    getTooltipItem: (group, _, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'In' : 'Out';
                      return BarTooltipItem(
                        '$label: \$${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        if (idx % showEvery != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            buckets[idx].label,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.grayText),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(buckets.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: buckets[i].income,
                        color: Colors.green,
                        width: buckets.length > 15 ? 4 : 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: buckets[i].expense,
                        color: Colors.redAccent,
                        width: buckets.length > 15 ? 4 : 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    barsSpace: 2,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.grayText)),
      ],
    );
  }
}
