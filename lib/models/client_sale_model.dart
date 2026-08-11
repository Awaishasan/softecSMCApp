import 'package:cloud_firestore/cloud_firestore.dart';

enum SalePaymentStatus { paid, credit, partial }
enum DiscountType { percentage, fixed }

class ClientSaleModel {
  final String id;
  final String clientId;
  final String itemDescription;
  final double totalAmount;
  final double paidAmount;
  final SalePaymentStatus status;
  final DateTime date;
  final DateTime? dueDate;
  final String userId;

  // Inventory integration fields
  final String? inventoryItemId;
  final String? productName;
  final int? quantity;
  final double? unitPrice;
  final double? discount;
  final DiscountType? discountType;
  final double? finalAmount;

  // Offline-first fields
  final String? firestoreId;
  final String syncStatus;

  ClientSaleModel({
    required this.id,
    required this.clientId,
    required this.itemDescription,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.date,
    this.dueDate,
    required this.userId,
    // Inventory fields (optional for backward compatibility)
    this.inventoryItemId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.discount,
    this.discountType,
    this.finalAmount,
    this.firestoreId,
    this.syncStatus = 'synced',
  });

  double get pendingAmount => totalAmount - paidAmount;

  bool get hasInventoryData => inventoryItemId != null && quantity != null;

  factory ClientSaleModel.fromMap(Map<String, dynamic> m, String docId) {
    return ClientSaleModel(
      id: docId,
      clientId: m['clientId'] ?? '',
      itemDescription: m['itemDescription'] ?? '',
      totalAmount: (m['totalAmount'] as num).toDouble(),
      paidAmount: (m['paidAmount'] as num?)?.toDouble() ?? 0,
      status: SalePaymentStatus.values.firstWhere(
        (e) => e.name == m['status'],
        orElse: () => SalePaymentStatus.paid,
      ),
      date: (m['date'] as Timestamp).toDate(),
      dueDate: m['dueDate'] != null
          ? (m['dueDate'] as Timestamp).toDate()
          : null,
      userId: m['userId'] ?? '',
      // Inventory fields
      inventoryItemId: m['inventoryItemId'],
      productName: m['productName'],
      quantity: m['quantity'] != null ? (m['quantity'] as num).toInt() : null,
      unitPrice: m['unitPrice'] != null ? (m['unitPrice'] as num).toDouble() : null,
      discount: m['discount'] != null ? (m['discount'] as num).toDouble() : null,
      discountType: m['discountType'] != null
          ? DiscountType.values.firstWhere(
              (e) => e.name == m['discountType'],
              orElse: () => DiscountType.fixed,
            )
          : null,
      finalAmount: m['finalAmount'] != null ? (m['finalAmount'] as num).toDouble() : null,
      firestoreId: m['firestoreId'],
      syncStatus: m['syncStatus'] ?? 'synced',
    );
  }

  factory ClientSaleModel.fromSqlite(Map<String, dynamic> m) {
    return ClientSaleModel(
      id: m['localId'] as String,
      clientId: m['clientId'] as String,
      itemDescription: m['itemDescription'] as String,
      totalAmount: (m['totalAmount'] as num).toDouble(),
      paidAmount: (m['paidAmount'] as num).toDouble(),
      status: SalePaymentStatus.values.firstWhere(
        (e) => e.name == m['status'],
        orElse: () => SalePaymentStatus.paid,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      dueDate: m['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(m['dueDate'] as int)
          : null,
      userId: m['userId'] as String,
      inventoryItemId: m['inventoryItemId'] as String?,
      productName: m['productName'] as String?,
      quantity: m['quantity'] != null ? (m['quantity'] as num).toInt() : null,
      unitPrice: m['unitPrice'] != null ? (m['unitPrice'] as num).toDouble() : null,
      discount: m['discount'] != null ? (m['discount'] as num).toDouble() : null,
      discountType: m['discountType'] != null
          ? DiscountType.values.firstWhere(
              (e) => e.name == m['discountType'],
              orElse: () => DiscountType.fixed,
            )
          : null,
      finalAmount: m['finalAmount'] != null ? (m['finalAmount'] as num).toDouble() : null,
      firestoreId: m['firestoreId'] as String?,
      syncStatus: m['syncStatus'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'clientId': clientId,
      'itemDescription': itemDescription,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.name,
      'date': Timestamp.fromDate(date),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'userId': userId,
      'firestoreId': firestoreId,
      'syncStatus': syncStatus,
    };

    // Add inventory fields only if they have values
    if (inventoryItemId != null) map['inventoryItemId'] = inventoryItemId;
    if (productName != null) map['productName'] = productName;
    if (quantity != null) map['quantity'] = quantity;
    if (unitPrice != null) map['unitPrice'] = unitPrice;
    if (discount != null) map['discount'] = discount;
    if (discountType != null) map['discountType'] = discountType!.name;
    if (finalAmount != null) map['finalAmount'] = finalAmount;

    return map;
  }

  Map<String, dynamic> toSqlite() {
    final map = {
      'localId': id,
      'clientId': clientId,
      'itemDescription': itemDescription,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.name,
      'date': date.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'userId': userId,
      'firestoreId': firestoreId,
      'syncStatus': syncStatus,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (inventoryItemId != null) map['inventoryItemId'] = inventoryItemId;
    if (productName != null) map['productName'] = productName;
    if (quantity != null) map['quantity'] = quantity;
    if (unitPrice != null) map['unitPrice'] = unitPrice;
    if (discount != null) map['discount'] = discount;
    if (discountType != null) map['discountType'] = discountType!.name;
    if (finalAmount != null) map['finalAmount'] = finalAmount;

    return map;
  }

  String get statusLabel {
    switch (status) {
      case SalePaymentStatus.paid:
        return 'Paid';
      case SalePaymentStatus.credit:
        return 'Credit';
      case SalePaymentStatus.partial:
        return 'Partial';
    }
  }

  String get discountLabel {
    if (discount == null || discount == 0) return 'No Discount';
    if (discountType == DiscountType.percentage) {
      return '${discount!.toStringAsFixed(0)}%';
    }
    return 'Rs ${discount!.toStringAsFixed(0)}';
  }

  ClientSaleModel copyWith({
    String? id,
    String? clientId,
    String? itemDescription,
    double? totalAmount,
    double? paidAmount,
    SalePaymentStatus? status,
    DateTime? date,
    DateTime? dueDate,
    String? userId,
    String? inventoryItemId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? discount,
    DiscountType? discountType,
    double? finalAmount,
    String? firestoreId,
    String? syncStatus,
  }) {
    return ClientSaleModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      itemDescription: itemDescription ?? this.itemDescription,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      finalAmount: finalAmount ?? this.finalAmount,
      firestoreId: firestoreId ?? this.firestoreId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
