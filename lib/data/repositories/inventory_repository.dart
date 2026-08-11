import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:softec_sme_app/data/local/database_helper.dart';
import 'package:softec_sme_app/models/inventory_item.dart';
import 'package:uuid/uuid.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final String _tableName = 'inventory_items';

  Future<List<InventoryItem>> getItems() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'syncStatus != ?',
      whereArgs: ['pending_delete'],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((m) => InventoryItem.fromSqlite(m)).toList();
  }

  Future<InventoryItem> addItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    final localId = _uuid.v4();
    
    final newItem = item.copyWith(
      id: localId,
      syncStatus: 'pending_create',
    );

    await db.insert(_tableName, newItem.toSqlite());
    return newItem;
  }

  Future<InventoryItem> updateItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    
    // If it's already pending_create, keep it pending_create. 
    // Otherwise it's pending_update.
    final currentStatus = item.syncStatus;
    final newStatus = currentStatus == 'pending_create' ? 'pending_create' : 'pending_update';
    
    final updatedItem = item.copyWith(
      syncStatus: newStatus,
      updatedAt: DateTime.now(),
    );

    await db.update(
      _tableName,
      updatedItem.toSqlite(),
      where: 'localId = ?',
      whereArgs: [updatedItem.id],
    );
    
    return updatedItem;
  }

  Future<void> deleteItem(String localId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      _tableName,
      where: 'localId = ?',
      whereArgs: [localId],
    );
    
    if (maps.isNotEmpty) {
      final item = InventoryItem.fromSqlite(maps.first);
      if (item.syncStatus == 'pending_create') {
        // If it was never synced, just delete it locally
        await db.delete(
          _tableName,
          where: 'localId = ?',
          whereArgs: [localId],
        );
      } else {
        // Mark as pending_delete
        final deletedItem = item.copyWith(syncStatus: 'pending_delete');
        await db.update(
          _tableName,
          deletedItem.toSqlite(),
          where: 'localId = ?',
          whereArgs: [localId],
        );
      }
    }
  }
}
