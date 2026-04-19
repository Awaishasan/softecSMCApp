import 'package:cloud_firestore/cloud_firestore.dart';

enum SalePaymentStatus { paid, credit, partial }

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
  });

  double get pendingAmount => totalAmount - paidAmount;

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
    );
  }

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'itemDescription': itemDescription,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'status': status.name,
        'date': Timestamp.fromDate(date),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'userId': userId,
      };

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
}
