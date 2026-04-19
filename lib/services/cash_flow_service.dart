import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class CashFlowService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _txCol =>
      _db.collection('users').doc(_uid).collection('transactions');

  DocumentReference get _summaryDoc =>
      _db.collection('users').doc(_uid);

  // Add a transaction and update summary atomically
  Future<void> addTransaction({
    required String title,
    required String subtitle,
    required double amount,
    required TransactionType type,
  }) async {
    final batch = _db.batch();

    final txRef = _txCol.doc();
    batch.set(txRef, TransactionModel(
      id: txRef.id,
      title: title,
      subtitle: subtitle,
      amount: amount,
      type: type,
      createdAt: DateTime.now(),
      userId: _uid,
    ).toMap());

    // Update summary counters
    final Map<String, dynamic> summaryUpdate = {};
    switch (type) {
      case TransactionType.income:
        summaryUpdate['totalBalance'] = FieldValue.increment(amount);
        summaryUpdate['monthlySales'] = FieldValue.increment(amount);
        summaryUpdate['pendingReceivables'] = FieldValue.increment(amount);
        break;
      case TransactionType.expense:
        summaryUpdate['totalBalance'] = FieldValue.increment(-amount);
        summaryUpdate['monthlyExpenses'] = FieldValue.increment(amount);
        summaryUpdate['pendingPayables'] = FieldValue.increment(amount);
        break;
      case TransactionType.transfer:
        summaryUpdate['totalBalance'] = FieldValue.increment(amount);
        break;
    }
    batch.set(_summaryDoc, summaryUpdate, SetOptions(merge: true));

    await batch.commit();
  }

  // Fetch summary data
  Future<Map<String, dynamic>> fetchSummary() async {
    final doc = await _summaryDoc.get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>;
  }

  // Delete a transaction (does not reverse summary — use with care)
  Future<void> deleteTransaction(String txId) async {
    await _txCol.doc(txId).delete();
  }

  // Stream recent 10 transactions (home screen)
  Stream<List<TransactionModel>> transactionsStream() {
    return _txCol
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TransactionModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // Stream ALL transactions (analytics screen)
  Stream<List<TransactionModel>> allTransactionsStream() {
    return _txCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TransactionModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }
}
