import 'package:flutter/material.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';

class AnalyticsFilterTabs extends StatelessWidget {
  final CashFlowController ctrl;
  const AnalyticsFilterTabs({super.key, required this.ctrl});

  static const _labels = ['All', 'Income', 'Expense'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final selected = ctrl.typeFilter == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => ctrl.setTypeFilter(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.grayText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
