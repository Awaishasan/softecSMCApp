import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense, transfer }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime createdAt;
  final String userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.userId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  String get formattedAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    return '${prefix}Rs ${amount.toStringAsFixed(2)}';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
