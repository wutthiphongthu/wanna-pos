import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

final Migration migration1to2 = Migration(1, 2, (sqflite.Database db) async {
  // Align product schema with provided Excel export.
  await db.execute('ALTER TABLE products ADD COLUMN productSubname TEXT');
  await db.execute(
      'ALTER TABLE products ADD COLUMN discountType INTEGER NOT NULL DEFAULT 1');
  await db.execute(
      'ALTER TABLE products ADD COLUMN discount REAL NOT NULL DEFAULT 0');
  await db.execute(
      'ALTER TABLE products ADD COLUMN barcodeType INTEGER NOT NULL DEFAULT 1');
  await db.execute('ALTER TABLE products ADD COLUMN customBarcodeId TEXT');
  await db.execute(
      'ALTER TABLE products ADD COLUMN hideInEcommerce INTEGER NOT NULL DEFAULT 0');
  await db.execute(
      'ALTER TABLE products ADD COLUMN nonVat INTEGER NOT NULL DEFAULT 0');
  await db.execute(
      'ALTER TABLE products ADD COLUMN unlimitedStock INTEGER NOT NULL DEFAULT 0');
  await db.execute(
      'ALTER TABLE products ADD COLUMN hideInEMenu INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE products ADD COLUMN productLocation TEXT');
});

final Migration migration2to3 = Migration(2, 3, (sqflite.Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS members (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      memberCode TEXT NOT NULL,
      name TEXT NOT NULL,
      email TEXT,
      phone TEXT,
      membershipLevel TEXT NOT NULL,
      points INTEGER NOT NULL DEFAULT 0,
      isActive INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS index_members_memberCode ON members (memberCode)');
});

final Migration migration3to4 = Migration(3, 4, (sqflite.Database db) async {
  // Create stores table
  await db.execute('''
    CREATE TABLE IF NOT EXISTS stores (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT NOT NULL,
      address TEXT,
      phone TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  // Insert default stores
  final now = DateTime.now().millisecondsSinceEpoch;
  await db.execute(
    'INSERT INTO stores (id, name, address, phone, is_active, created_at, updated_at) VALUES (1, ?, ?, ?, 1, ?, ?)',
    ['ร้านหลัก', null, null, now, now],
  );
  await db.execute(
    'INSERT INTO stores (id, name, address, phone, is_active, created_at, updated_at) VALUES (2, ?, ?, ?, 1, ?, ?)',
    ['สาขา 2', null, null, now, now],
  );

  // Add store_id to products
  await db.execute('ALTER TABLE products ADD COLUMN store_id INTEGER NOT NULL DEFAULT 1');
  // Add store_id to members
  await db.execute('ALTER TABLE members ADD COLUMN store_id INTEGER NOT NULL DEFAULT 1');
  // Add store_id to CategoryEntity (Floor default table name)
  await db.execute('ALTER TABLE CategoryEntity ADD COLUMN store_id INTEGER NOT NULL DEFAULT 1');
  // Add store_id to sales
  await db.execute('ALTER TABLE sales ADD COLUMN store_id INTEGER NOT NULL DEFAULT 1');
});

final Migration migration4to5 = Migration(4, 5, (sqflite.Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS sale_line_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      sale_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      item_discount REAL NOT NULL DEFAULT 0,
      line_total REAL NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales (id)
    )
  ''');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS index_sale_line_items_sale_id ON sale_line_items (sale_id)');
});

final Migration migration5to6 = Migration(5, 6, (sqflite.Database db) async {
  await db.execute('ALTER TABLE sales ADD COLUMN customer_name TEXT DEFAULT ""');
  await db.execute('ALTER TABLE sales ADD COLUMN amount_received REAL NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE sales ADD COLUMN change_amount REAL NOT NULL DEFAULT 0');
});

/// Offline-first sync metadata (remote Firestore doc id + dirty flag)
final Migration migration6to7 = Migration(6, 7, (sqflite.Database db) async {
  await db.execute('ALTER TABLE products ADD COLUMN remote_id TEXT');
  await db.execute(
      'ALTER TABLE products ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE members ADD COLUMN remote_id TEXT');
  await db.execute(
      'ALTER TABLE members ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE CategoryEntity ADD COLUMN remote_id TEXT');
  await db.execute(
      'ALTER TABLE CategoryEntity ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE sales ADD COLUMN remote_id TEXT');
  await db.execute(
      'ALTER TABLE sales ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE sale_line_items ADD COLUMN remote_id TEXT');
  await db.execute(
      'ALTER TABLE sale_line_items ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 0');
});

