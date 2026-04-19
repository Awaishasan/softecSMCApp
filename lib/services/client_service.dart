import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client_model.dart';
import '../models/client_sale_model.dart';

class ClientService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _clientsCol =>
      _db.collection('users').doc(_uid).collection('clients');

  CollectionReference _salesCol(String clientId) =>
      _clientsCol.doc(clientId).collection('sales');



  Stream<List<ClientModel>> clientsStream() {
    return _clientsCol
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                ClientModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> addClient(ClientModel client) async {
    final ref = _clientsCol.doc();
    await ref.set(ClientModel(
      id: ref.id,
      name: client.name,
      phone: client.phone,
      email: client.email,
      address: client.address,
      type: client.type,
      joinDate: client.joinDate,
      userId: _uid,
    ).toMap());
  }

  Future<void> updateClient(ClientModel client) async {
    await _clientsCol.doc(client.id).update(client.toMap());
  }

  Future<void> deleteClient(String clientId) async {
    await _clientsCol.doc(clientId).delete();
  }



  Stream<List<ClientSaleModel>> salesStream(String clientId) {
    return _salesCol(clientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ClientSaleModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> addSale(ClientSaleModel sale) async {
    final batch = _db.batch();

    final saleRef = _salesCol(sale.clientId).doc();
    batch.set(saleRef, ClientSaleModel(
      id: saleRef.id,
      clientId: sale.clientId,
      itemDescription: sale.itemDescription,
      totalAmount: sale.totalAmount,
      paidAmount: sale.paidAmount,
      status: sale.status,
      date: sale.date,
      dueDate: sale.dueDate,
      userId: _uid,
    ).toMap());

    final outstanding = sale.totalAmount - sale.paidAmount;
    batch.update(_clientsCol.doc(sale.clientId), {
      'totalSpend': FieldValue.increment(sale.totalAmount),
      'outstandingBalance': FieldValue.increment(outstanding),
      'lastVisit': Timestamp.fromDate(sale.date),
    });

    await batch.commit();
  }


  Future<void> recordPayment({
    required String clientId,
    required String saleId,
    required double paymentAmount,
    required double currentPaid,
    required double totalAmount,
  }) async {
    final newPaid = currentPaid + paymentAmount;
    final newStatus = newPaid >= totalAmount
        ? SalePaymentStatus.paid
        : SalePaymentStatus.partial;

    final batch = _db.batch();

    batch.update(_salesCol(clientId).doc(saleId), {
      'paidAmount': newPaid,
      'status': newStatus.name,
    });


    batch.update(_clientsCol.doc(clientId), {
      'outstandingBalance': FieldValue.increment(-paymentAmount),
    });

    await batch.commit();
  }

  /// Stream all paid sales across ALL clients using collectionGroup
  Stream<List<Map<String, dynamic>>> allPaidSalesStream() {
    return _db
        .collectionGroup('sales')
        .where('userId', isEqualTo: _uid)
        .where('status', isEqualTo: SalePaymentStatus.paid.name)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final clientId = d.reference.parent.parent?.id ?? '';
              return {...data, 'id': d.id, 'clientId': clientId};
            }).toList());
  }
}
