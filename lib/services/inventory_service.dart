import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _inventoryCol =>
      _db.collection('users').doc(_uid).collection('inventory');

  // Stream all inventory items
  Stream<List<InventoryItem>> itemsStream() {
    return _inventoryCol
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // Get a single item by ID
  Future<InventoryItem?> getItem(String itemId) async {
    final doc = await _inventoryCol.doc(itemId).get();
    if (!doc.exists) return null;
    return InventoryItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Add new inventory item
  Future<void> addItem(InventoryItem item) async {
    final ref = _inventoryCol.doc();
    ref.set(InventoryItem(
      id: ref.id,
      name: item.name,
      category: item.category,
      sku: item.sku,
      company: item.company,
      costPrice: item.costPrice,
      sellingPrice: item.sellingPrice,
      quantity: item.quantity,
      lowStockThreshold: item.lowStockThreshold,
      imageUrl: item.imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toMap());
  }

  // Update existing inventory item
  Future<void> updateItem(InventoryItem item) async {
    _inventoryCol.doc(item.id).update({
      ...item.toMap(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Delete inventory item
  Future<void> deleteItem(String itemId) async {
    _inventoryCol.doc(itemId).delete();
  }

  // Increase stock
  Future<void> increaseStock(String itemId, int amount) async {
    _inventoryCol.doc(itemId).update({
      'quantity': FieldValue.increment(amount),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Decrease stock
  Future<void> decreaseStock(String itemId, int amount) async {
    _inventoryCol.doc(itemId).update({
      'quantity': FieldValue.increment(-amount),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Search items by name or SKU
  Stream<List<InventoryItem>> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _inventoryCol
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .where((item) =>
                item.name.toLowerCase().contains(lowerQuery) ||
                item.sku.toLowerCase().contains(lowerQuery))
            .toList());
  }

  // Filter by category
  Stream<List<InventoryItem>> filterByCategory(String category) {
    return _inventoryCol
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // Get low stock items
  Stream<List<InventoryItem>> lowStockItems() {
    return _inventoryCol
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .where((item) => item.isLowStock)
            .toList());
  }

  // Get out of stock items
  Stream<List<InventoryItem>> outOfStockItems() {
    return _inventoryCol
        .where('quantity', isEqualTo: 0)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InventoryItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // Calculate total inventory value
  Future<double> calculateInventoryValue() async {
    QuerySnapshot snapshot;
    try {
      snapshot = await _inventoryCol.get().timeout(const Duration(seconds: 2));
    } catch (_) {
      snapshot = await _inventoryCol.get(const GetOptions(source: Source.cache));
    }
    
    double total = 0.0;
    for (final doc in snapshot.docs) {
      final item = InventoryItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      total += item.stockValue;
    }
    return total;
  }

  // Get all unique categories
  Future<List<String>> getCategories() async {
    QuerySnapshot snapshot;
    try {
      snapshot = await _inventoryCol.get().timeout(const Duration(seconds: 2));
    } catch (_) {
      snapshot = await _inventoryCol.get(const GetOptions(source: Source.cache));
    }
    
    final cats = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['category'] as String? ?? '')
        .where((cat) => cat.isNotEmpty && cat != 'All')
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  // Delete category (move items to General)
  Future<void> deleteCategory(String categoryName) async {
    final snapshot = await _inventoryCol.where('category', isEqualTo: categoryName).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'category': 'General', 'updatedAt': Timestamp.fromDate(DateTime.now())});
    }
    await batch.commit();
  }
}
