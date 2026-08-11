import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String? company;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int lowStockThreshold;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Offline-first fields
  final String? firestoreId;
  final String syncStatus;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    this.company,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.lowStockThreshold,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.firestoreId,
    this.syncStatus = 'synced',
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
      company: m['company'],
      costPrice: (m['costPrice'] as num).toDouble(),
      sellingPrice: (m['sellingPrice'] as num).toDouble(),
      quantity: (m['quantity'] as num).toInt(),
      lowStockThreshold: (m['lowStockThreshold'] as num).toInt(),
      imageUrl: m['imageUrl'],
      createdAt: (m['createdAt'] as Timestamp).toDate(),
      updatedAt: (m['updatedAt'] as Timestamp).toDate(),
      firestoreId: m['firestoreId'],
      syncStatus: m['syncStatus'] ?? 'synced',
    );
  }

  factory InventoryItem.fromSqlite(Map<String, dynamic> m) {
    return InventoryItem(
      id: m['localId'] as String,
      firestoreId: m['firestoreId'] as String?,
      syncStatus: m['syncStatus'] as String,
      name: m['name'] as String,
      category: m['category'] as String,
      sku: m['sku'] as String,
      company: m['company'] as String?,
      costPrice: (m['costPrice'] as num).toDouble(),
      sellingPrice: (m['sellingPrice'] as num).toDouble(),
      quantity: (m['quantity'] as num).toInt(),
      lowStockThreshold: (m['lowStockThreshold'] as num).toInt(),
      imageUrl: m['imageUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'sku': sku,
        'company': company,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'firestoreId': firestoreId,
        'syncStatus': syncStatus,
      };

  Map<String, dynamic> toSqlite() => {
        'localId': id,
        'firestoreId': firestoreId,
        'syncStatus': syncStatus,
        'name': name,
        'category': category,
        'sku': sku,
        'company': company,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
        'imageUrl': imageUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? sku,
    String? company,
    double? costPrice,
    double? sellingPrice,
    int? quantity,
    int? lowStockThreshold,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firestoreId,
    String? syncStatus,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      company: company ?? this.company,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firestoreId: firestoreId ?? this.firestoreId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
