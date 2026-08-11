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

  // Offline-first fields
  final String? firestoreId;
  final String syncStatus;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.userId,
    this.firestoreId,
    this.syncStatus = 'synced',
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
      firestoreId: map['firestoreId'],
      syncStatus: map['syncStatus'] ?? 'synced',
    );
  }

  factory TransactionModel.fromSqlite(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['localId'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      userId: map['userId'] as String,
      firestoreId: map['firestoreId'] as String?,
      syncStatus: map['syncStatus'] as String,
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
      'firestoreId': firestoreId,
      'syncStatus': syncStatus,
    };
  }

  Map<String, dynamic> toSqlite() {
    return {
      'localId': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
      'firestoreId': firestoreId,
      'syncStatus': syncStatus,
      // Use standard int timestamp for sqlite
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  String get formattedAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    return '${prefix}Rs ${amount.toStringAsFixed(2)}';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    TransactionType? type,
    DateTime? createdAt,
    String? userId,
    String? firestoreId,
    String? syncStatus,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      firestoreId: firestoreId ?? this.firestoreId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
