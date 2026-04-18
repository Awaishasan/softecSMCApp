import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';

class AnalyticsDateFilter extends StatelessWidget {
  final CashFlowController ctrl;
  const AnalyticsDateFilter({super.key, required this.ctrl});

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ctrl.setCustomDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DateChip(
            label: '7 Days',
            selected: ctrl.dateFilter == DateRangeFilter.last7,
            onTap: () => ctrl.setDateFilter(DateRangeFilter.last7),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: '30 Days',
            selected: ctrl.dateFilter == DateRangeFilter.last30,
            onTap: () => ctrl.setDateFilter(DateRangeFilter.last30),
          ),
          const SizedBox(width: 8),
          _DateChip(
            label: ctrl.dateFilter == DateRangeFilter.custom &&
                    ctrl.customFrom != null
                ? '${ctrl.customFrom!.day}/${ctrl.customFrom!.month} – ${ctrl.customTo!.day}/${ctrl.customTo!.month}'
                : 'Custom',
            selected: ctrl.dateFilter == DateRangeFilter.custom,
            icon: Icons.calendar_today_rounded,
            onTap: () => _pickCustomRange(context),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryBlue
                : AppColors.dividerGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: selected ? Colors.white : AppColors.grayText),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.grayText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
