import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('softec_sme.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE inventory_items ADD COLUMN company TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNull = 'INTEGER';
    const realType = 'REAL NOT NULL';
    const realTypeNull = 'REAL';

    // Common sync fields for all tables:
    // localId: TEXT PRIMARY KEY
    // firestoreId: TEXT NULL
    // syncStatus: TEXT (pending_create, pending_update, pending_delete, synced)
    // createdAt: INTEGER
    // updatedAt: INTEGER

    await db.execute('''
CREATE TABLE inventory_items (
  localId $idType,
  firestoreId $textTypeNull,
  syncStatus $textType,
  name $textType,
  category $textType,
  sku $textType,
  company $textTypeNull,
  costPrice $realType,
  sellingPrice $realType,
  quantity $integerType,
  lowStockThreshold $integerType,
  imageUrl $textTypeNull,
  createdAt $integerType,
  updatedAt $integerType
)
''');

    await db.execute('''
CREATE TABLE transactions (
  localId $idType,
  firestoreId $textTypeNull,
  syncStatus $textType,
  title $textType,
  subtitle $textType,
  amount $realType,
  type $textType,
  userId $textType,
  createdAt $integerType,
  updatedAt $integerType
)
''');

    await db.execute('''
CREATE TABLE clients (
  localId $idType,
  firestoreId $textTypeNull,
  syncStatus $textType,
  name $textType,
  phone $textType,
  email $textType,
  address $textType,
  type $textType,
  joinDate $integerType,
  totalSpend $realType,
  outstandingBalance $realType,
  lastVisit $integerTypeNull,
  userId $textType,
  createdAt $integerType,
  updatedAt $integerType
)
''');

    await db.execute('''
CREATE TABLE client_sales (
  localId $idType,
  firestoreId $textTypeNull,
  syncStatus $textType,
  clientId $textType,
  itemDescription $textType,
  totalAmount $realType,
  paidAmount $realType,
  status $textType,
  date $integerType,
  dueDate $integerTypeNull,
  userId $textType,
  inventoryItemId $textTypeNull,
  productName $textTypeNull,
  quantity $integerTypeNull,
  unitPrice $realTypeNull,
  discount $realTypeNull,
  discountType $textTypeNull,
  finalAmount $realTypeNull,
  createdAt $integerType,
  updatedAt $integerType
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
