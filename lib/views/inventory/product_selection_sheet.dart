import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/inventory_item.dart';
import '../../res/app_colors.dart';
import '../../view_models/inventory_controller.dart';

class ProductSelectionSheet extends StatelessWidget {
  final Function(InventoryItem) onProductSelected;

  const ProductSelectionSheet({super.key, required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (ctrl) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Select Product',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textBlue),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  onChanged: ctrl.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.iconBlue),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Products List
              Expanded(
                child: ctrl.filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: AppColors.grayText),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ctrl.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = ctrl.filteredItems[index];
                          return _buildProductCard(item, onProductSelected);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(InventoryItem item, Function(InventoryItem) onSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.back();
          onSelected(item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image or Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  image: item.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl == null
                    ? const Icon(Icons.inventory_2_outlined,
                        color: AppColors.iconBlue, size: 24)
                    : null,
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grayText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Rs ${item.sellingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isOutOfStock
                                ? Colors.red.withOpacity(0.1)
                                : item.isLowStock
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: item.isOutOfStock
                                  ? Colors.red
                                  : item.isLowStock
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.chevron_right,
                color: AppColors.iconBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
