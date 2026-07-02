import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/inventory_item.dart';
import '../../res/app_colors.dart';
import '../../view_models/inventory_controller.dart';
import '../../widgets/inventory_product_card.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (ctrl) {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: null,
            onPressed: _openAddProduct,
            backgroundColor: AppColors.primaryBlue,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Product',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Summary Cards
                _buildSummaryCards(ctrl),
                const SizedBox(height: 12),

                // Search and Filters
                _buildSearchAndFilters(ctrl),
                const SizedBox(height: 8),

                // Products List
                Expanded(
                  child: ctrl.filteredItems.isEmpty
                      ? _buildEmptyState(ctrl.searchQuery.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: ctrl.filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = ctrl.filteredItems[index];
                            return InventoryProductCard(
                              item: item,
                              onTap: () => Get.to(() => ProductDetailsScreen(item: item)),
                              onEdit: () => _openAddProduct(item: item),
                              onDelete: () => _showDeleteDialog(ctrl, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(InventoryController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Products',
              '${ctrl.totalItems}',
              Icons.inventory_2_outlined,
              AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Quantity',
              '${ctrl.totalQuantity}',
              Icons.inventory,
              AppColors.iconBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(InventoryController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips + Sort
          Row(
            children: [
              // Scrollable filter chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(ctrl, InventoryFilter.all, 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip(ctrl, InventoryFilter.lowStock, 'Low Stock'),
                      const SizedBox(width: 8),
                      _buildFilterChip(ctrl, InventoryFilter.outOfStock, 'Out of Stock'),
                    ],
                  ),
                ),
              ),
              // Sort Dropdown
              PopupMenuButton<InventorySort>(
                icon: const Icon(Icons.sort, color: AppColors.iconBlue),
                onSelected: ctrl.setSort,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: InventorySort.name,
                    child: Text('Sort by Name'),
                  ),
                  const PopupMenuItem(
                    value: InventorySort.quantity,
                    child: Text('Sort by Quantity'),
                  ),
                  const PopupMenuItem(
                    value: InventorySort.price,
                    child: Text('Sort by Price'),
                  ),
                ],
              ),
            ],
          ),

          // Category Filter
          if (ctrl.categories.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.categories.length,
                  itemBuilder: (context, index) {
                    final category = ctrl.categories[index];
                    final isSelected = ctrl.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => ctrl.setCategory(category),
                        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryBlue : AppColors.grayText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    InventoryController ctrl,
    InventoryFilter filter,
    String label,
  ) {
    final isSelected = ctrl.filterOption == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ctrl.setFilter(filter),
      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryBlue : AppColors.grayText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.grayText,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No products found' : 'No products yet',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 8),
          if (!isSearch)
            const Text(
              'Tap + to add your first product',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grayText,
              ),
            ),
        ],
      ),
    );
  }

  void _openAddProduct({InventoryItem? item}) {
    Get.to(() => AddProductScreen(item: item));
  }

  void _showDeleteDialog(InventoryController ctrl, InventoryItem item) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete ${item.name}?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        ctrl.deleteItem(item.id);
      },
    );
  }
}
