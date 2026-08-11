import 'package:cloud_firestore/cloud_firestore.dart';

enum ClientType { walkIn, regular, vip }

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final ClientType type;
  final DateTime joinDate;
  final double totalSpend;
  final double outstandingBalance; // total udhar baaki
  final DateTime? lastVisit;
  final String userId;

  // Offline-first fields
  final String? firestoreId;
  final String syncStatus;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.type,
    required this.joinDate,
    this.totalSpend = 0,
    this.outstandingBalance = 0,
    this.lastVisit,
    required this.userId,
    this.firestoreId,
    this.syncStatus = 'synced',
  });

  factory ClientModel.fromMap(Map<String, dynamic> m, String docId) {
    return ClientModel(
      id: docId,
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      email: m['email'] ?? '',
      address: m['address'] ?? '',
      type: ClientType.values.firstWhere((e) => e.name == m['type'],
        orElse: () => ClientType.walkIn,
      ),
      joinDate: (m['joinDate'] as Timestamp).toDate(),
      totalSpend: (m['totalSpend'] as num?)?.toDouble() ?? 0,
      outstandingBalance:
          (m['outstandingBalance'] as num?)?.toDouble() ?? 0,
      lastVisit: m['lastVisit'] != null
          ? (m['lastVisit'] as Timestamp).toDate()
          : null,
      userId: m['userId'] ?? '',
      firestoreId: m['firestoreId'],
      syncStatus: m['syncStatus'] ?? 'synced',
    );
  }

  factory ClientModel.fromSqlite(Map<String, dynamic> m) {
    return ClientModel(
      id: m['localId'] as String,
      name: m['name'] as String,
      phone: m['phone'] as String,
      email: m['email'] as String,
      address: m['address'] as String,
      type: ClientType.values.firstWhere(
        (e) => e.name == m['type'],
        orElse: () => ClientType.walkIn,
      ),
      joinDate: DateTime.fromMillisecondsSinceEpoch(m['joinDate'] as int),
      totalSpend: (m['totalSpend'] as num).toDouble(),
      outstandingBalance: (m['outstandingBalance'] as num).toDouble(),
      lastVisit: m['lastVisit'] != null
          ? DateTime.fromMillisecondsSinceEpoch(m['lastVisit'] as int)
          : null,
      userId: m['userId'] as String,
      firestoreId: m['firestoreId'] as String?,
      syncStatus: m['syncStatus'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'type': type.name,
        'joinDate': Timestamp.fromDate(joinDate),
        'totalSpend': totalSpend,
        'outstandingBalance': outstandingBalance,
        'lastVisit':
            lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
        'userId': userId,
        'firestoreId': firestoreId,
        'syncStatus': syncStatus,
      };

  Map<String, dynamic> toSqlite() => {
        'localId': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'type': type.name,
        'joinDate': joinDate.millisecondsSinceEpoch,
        'totalSpend': totalSpend,
        'outstandingBalance': outstandingBalance,
        'lastVisit': lastVisit?.millisecondsSinceEpoch,
        'userId': userId,
        'firestoreId': firestoreId,
        'syncStatus': syncStatus,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

  String get typeLabel {
    switch (type) {
      case ClientType.vip:
        return 'VIP';
      case ClientType.regular:
        return 'Regular';
      case ClientType.walkIn:
        return 'Walk-in';
    }
  }

  bool get hasBalance => outstandingBalance > 0;

  ClientModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    ClientType? type,
    DateTime? joinDate,
    double? totalSpend,
    double? outstandingBalance,
    DateTime? lastVisit,
    String? userId,
    String? firestoreId,
    String? syncStatus,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      type: type ?? this.type,
      joinDate: joinDate ?? this.joinDate,
      totalSpend: totalSpend ?? this.totalSpend,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      lastVisit: lastVisit ?? this.lastVisit,
      userId: userId ?? this.userId,
      firestoreId: firestoreId ?? this.firestoreId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
