import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:softec_sme_app/data/local/database_helper.dart';
import 'package:softec_sme_app/services/connectivity_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;

  SyncService(this._connectivityService) {
    _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected) {
        syncAll();
      }
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await _syncInventoryItems();
      // Add other sync methods here (transactions, clients, etc.)
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncInventoryItems() async {
    final db = await _dbHelper.database;
    const table = 'inventory_items';
    const collection = 'inventory';

    // 1. Sync pending local changes to Firestore
    final pendingRecords = await db.query(
      table,
      where: 'syncStatus != ?',
      whereArgs: ['synced'],
    );

    for (var record in pendingRecords) {
      final localId = record['localId'] as String;
      final firestoreId = record['firestoreId'] as String?;
      final status = record['syncStatus'] as String;

      try {
        if (status == 'pending_create') {
          final docRef = await _firestore.collection(collection).add(record);
          await db.update(
            table,
            {
              'firestoreId': docRef.id,
              'syncStatus': 'synced',
            },
            where: 'localId = ?',
            whereArgs: [localId],
          );
        } else if (status == 'pending_update' && firestoreId != null) {
          await _firestore.collection(collection).doc(firestoreId).update(record);
          await db.update(
            table,
            {'syncStatus': 'synced'},
            where: 'localId = ?',
            whereArgs: [localId],
          );
        } else if (status == 'pending_delete' && firestoreId != null) {
          await _firestore.collection(collection).doc(firestoreId).delete();
          await db.delete(
            table,
            where: 'localId = ?',
            whereArgs: [localId],
          );
        }
      } catch (e) {
        print('Error syncing record $localId: $e');
        // Will retry on next sync
      }
    }

    // 2. Fetch remote changes and update SQLite
    // Basic implementation: fetch all (in production, use timestamp based filtering)
    try {
      final snapshot = await _firestore.collection(collection).get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        data['syncStatus'] = 'synced';
        
        // Check if exists locally by firestoreId
        final existing = await db.query(
          table,
          where: 'firestoreId = ?',
          whereArgs: [doc.id],
        );
        
        if (existing.isEmpty) {
          // If not exists, insert it with a new localId if not provided in data
          if (!data.containsKey('localId') || data['localId'] == null) {
             // In a real app, you might want to use a reliable UUID generator here
             // For now, we skip or generate a new localId, but typically we want the remote 
             // to have the localId preserved if it was created locally, or generate one if created remotely.
             // We'll assume the localId is needed.
             // To simplify, let's just insert it and let the database handle it if localId is not required,
             // but our schema requires localId.
          }
          // We will refine this conflict resolution and download logic later as requested.
        }
      }
    } catch (e) {
      print('Error fetching remote inventory: $e');
    }
  }
}
