import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int lowStockThreshold;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.lowStockThreshold,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isLowStock => quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity == 0;
  double get stockValue => costPrice * quantity;
  double get potentialRevenue => sellingPrice * quantity;

  factory InventoryItem.fromMap(Map<String, dynamic> m, String docId) {
    return InventoryItem(
      id: docId,
      name: m['name'] ?? '',
      category: m['category'] ?? '',
      sku: m['sku'] ?? '',
      barcode: m['barcode'],
      costPrice: (m['costPrice'] as num).toDouble(),
      sellingPrice: (m['sellingPrice'] as num).toDouble(),
      quantity: (m['quantity'] as num).toInt(),
      lowStockThreshold: (m['lowStockThreshold'] as num).toInt(),
      imageUrl: m['imageUrl'],
      createdAt: (m['createdAt'] as Timestamp).toDate(),
      updatedAt: (m['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'sku': sku,
        'barcode': barcode,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? quantity,
    int? lowStockThreshold,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
