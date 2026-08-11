import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';

enum InventorySort { name, quantity, price }
enum InventoryFilter { all, lowStock, outOfStock }

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();

  List<InventoryItem> allItems = [];
  List<InventoryItem> filteredItems = [];
  
  String searchQuery = '';
  String selectedCategory = 'All';
  InventorySort sortOption = InventorySort.name;
  InventoryFilter filterOption = InventoryFilter.all;
  
  bool isLoading = true;
  bool isSubmitting = false;
  
  StreamSubscription? _itemsSub;
  List<String> categories = ['All'];

  // Computed values
  double get inventoryValue => allItems.fold(0.0, (sum, item) => sum + item.stockValue);
  int get totalItems => allItems.length;
  int get totalQuantity => allItems.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockCount => allItems.where((item) => item.isLowStock).length;
  int get outOfStockCount => allItems.where((item) => item.isOutOfStock).length;

  @override
  void onInit() {
    super.onInit();
    _loadItems();
    _loadCategories();
  }

  @override
  void onClose() {
    _itemsSub?.cancel();
    super.onClose();
  }

  void _loadItems() {
    _itemsSub = _service.itemsStream().listen((items) {
      allItems = items;
      _applyFilters();
      isLoading = false;
      update();
    });
  }

  Future<void> _loadCategories() async {
    final cats = await _service.getCategories();
    categories = ['All', ...cats];
    update();
  }

  void _applyFilters() {
    filteredItems = allItems;

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredItems = filteredItems
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.sku.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (selectedCategory != 'All') {
      filteredItems = filteredItems
          .where((item) => item.category == selectedCategory)
          .toList();
    }

    // Apply status filter
    switch (filterOption) {
      case InventoryFilter.lowStock:
        filteredItems = filteredItems.where((item) => item.isLowStock).toList();
        break;
      case InventoryFilter.outOfStock:
        filteredItems = filteredItems.where((item) => item.isOutOfStock).toList();
        break;
      case InventoryFilter.all:
        break;
    }

    // Apply sorting
    switch (sortOption) {
      case InventorySort.name:
        filteredItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case InventorySort.quantity:
        filteredItems.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case InventorySort.price:
        filteredItems.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
    update();
  }

  void setCategory(String category) {
    selectedCategory = category;
    _applyFilters();
    update();
  }

  void setSort(InventorySort sort) {
    sortOption = sort;
    _applyFilters();
    update();
  }

  void setFilter(InventoryFilter filter) {
    filterOption = filter;
    _applyFilters();
    update();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String sku,
    String? company,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    required int lowStockThreshold,
    String? imageUrl,
  }) async {
    isSubmitting = true;
    update();
    try {
      await _service.addItem(InventoryItem(
        id: '',
        name: name,
        category: category,
        sku: sku,
        company: company,
        costPrice: costPrice,
        sellingPrice: sellingPrice,
        quantity: quantity,
        lowStockThreshold: lowStockThreshold,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      _toast('Product added successfully');
      await _loadCategories();
    } catch (e) {
      print('ERROR in addItem: $e');
      _toast('Failed to add product: ${e.toString()}', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> updateItem(InventoryItem item) async {
    isSubmitting = true;
    update();
    try {
      await _service.updateItem(item.copyWith(updatedAt: DateTime.now()));
      _toast('Product updated successfully');
    } catch (e) {
      _toast('Failed to update product: $e', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> deleteItem(String itemId) async {
    isSubmitting = true;
    update();
    try {
      await _service.deleteItem(itemId);
      _toast('Product deleted successfully');
    } catch (e) {
      _toast('Failed to delete product: $e', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> deleteCategory(String categoryName) async {
    isSubmitting = true;
    update();
    try {
      await _service.deleteCategory(categoryName);
      if (selectedCategory == categoryName) {
        selectedCategory = 'All';
      }
      _toast('Category deleted successfully');
      await _loadCategories();
    } catch (e) {
      _toast('Failed to delete category: $e', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> adjustStock(String itemId, int amount) async {
    isSubmitting = true;
    update();
    try {
      // Find item to check current quantity
      final item = allItems.where((i) => i.id == itemId).firstOrNull;
      
      if (item != null) {
        if (amount < 0 && (item.quantity + amount) < 0) {
          _toast(item.quantity == 0 
            ? 'Stock is already zero and cannot be negative' 
            : 'Cannot reduce stock below zero. Current stock: ${item.quantity}', 
            isError: true);
          isSubmitting = false;
          update();
          return;
        }
      }

      if (amount > 0) {
        await _service.increaseStock(itemId, amount);
        _toast('Stock increased successfully');
      } else {
        await _service.decreaseStock(itemId, amount.abs());
        _toast('Stock decreased successfully');
      }
    } catch (e) {
      _toast('Failed to adjust stock: $e', isError: true);
    }
    isSubmitting = false;
    update();
  }

  void _toast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
    );
  }
}
