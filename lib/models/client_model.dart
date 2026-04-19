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
  });

  factory ClientModel.fromMap(Map<String, dynamic> m, String docId) {
    return ClientModel(
      id: docId,
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      email: m['email'] ?? '',
      address: m['address'] ?? '',
      type: ClientType.values.firstWhere(
        (e) => e.name == m['type'],
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
}
