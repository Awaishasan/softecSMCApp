import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/inventory_item.dart';
import '../../res/app_colors.dart';
import '../../view_models/inventory_controller.dart';
import 'add_product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final InventoryItem item;

  const ProductDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Product Details',
            style: TextStyle(color: AppColors.textBlue, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.iconBlue),
            onPressed: () => _showEditSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: GetBuilder<InventoryController>(
        builder: (ctrl) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: item.imageUrl == null
                      ? const Icon(Icons.inventory_2_outlined,
                          color: AppColors.iconBlue, size: 60)
                      : item.imageUrl!.startsWith('data:image')
                          ? Image.memory(
                              base64Decode(item.imageUrl!.split(',').last),
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: AppColors.iconBlue, size: 60),
                            )
                          : Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: AppColors.iconBlue, size: 60),
                            ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Name
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),

              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stock Status
              _buildStockStatus(),
              const SizedBox(height: 24),

              // Details Card
              _buildDetailCard(context, ctrl),
              const SizedBox(height: 24),

              // Stock Adjustment Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showStockAdjustment(context, ctrl, true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showStockAdjustment(context, ctrl, false),
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    if (item.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Out of Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else if (item.isLowStock) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 12),
            Text(
              'Low Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 12),
          Text(
            'In Stock',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, InventoryController ctrl) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('SKU', item.sku),
            _buildDetailRow('Barcode', item.barcode ?? 'N/A'),
            _buildDetailRow('Cost Price', 'Rs ${item.costPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Selling Price', 'Rs ${item.sellingPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Quantity', '${item.quantity} units'),
            _buildDetailRow('Low Stock Threshold', '${item.lowStockThreshold} units'),
            _buildDetailRow('Stock Value', 'Rs ${item.stockValue.toStringAsFixed(2)}'),
            _buildDetailRow('Potential Revenue', 'Rs ${item.potentialRevenue.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            _buildDetailRow('Created', _formatDate(item.createdAt)),
            _buildDetailRow('Last Updated', _formatDate(item.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grayText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditSheet(BuildContext context) {
    Get.to(() => AddProductScreen(item: item));
  }

  void _showDeleteDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete this product?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        Get.find<InventoryController>().deleteItem(item.id);
        Get.back();
      },
    );
  }

  void _showStockAdjustment(BuildContext context, InventoryController ctrl, bool isAdd) {
    final controller = TextEditingController();
    Get.defaultDialog(
      title: isAdd ? 'Add Stock' : 'Remove Stock',
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity',
            border: const OutlineInputBorder(),
            hintText: 'Enter quantity',
          ),
        ),
      ),
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      onConfirm: () {
        final quantity = int.tryParse(controller.text);
        if (quantity != null && quantity > 0) {
          ctrl.adjustStock(item.id, isAdd ? quantity : -quantity);
          Get.back();
        }
      },
    );
  }
}
