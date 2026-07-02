import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';
import '../view_models/inventory_controller.dart';

class InventorySummaryCard extends StatelessWidget {
  const InventorySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (ctrl) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ctrl.lowStockCount > 0
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ctrl.lowStockCount > 0 ? Icons.warning_amber_outlined : Icons.check_circle,
                        size: 16,
                        color: ctrl.lowStockCount > 0 ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          ctrl.lowStockCount > 0 ? '${ctrl.lowStockCount} Low Stock' : 'All Good',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ctrl.lowStockCount > 0 ? Colors.orange : Colors.green,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStat(
                    'Total Products',
                    '${ctrl.totalItems}',
                    Icons.inventory_2_outlined,
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStat(
                    'Total Quantity',
                    '${ctrl.totalQuantity}',
                    Icons.inventory,
                    AppColors.iconBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStat(
                    'Inventory Value',
                    'Rs ${ctrl.inventoryValue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStat(
                    'Out of Stock',
                    '${ctrl.outOfStockCount}',
                    Icons.error_outline,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}
