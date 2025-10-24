import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  /// Get database instance (initialize if not yet)
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    late String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final Directory appDir = await getApplicationSupportDirectory();
      dbPath = join(appDir.path, 'app_database.db');
    } else {
      // For mobile
      dbPath = join(await sqflite.getDatabasesPath(), 'app_database.db');
    }

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // You can create a default table here if needed
          print('📘 Database created at: $dbPath');
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🧱 Dynamic Table Creation
  // ------------------------------------------------------------------

  /// Create a table dynamically by only providing attribute names.
  /// Example:
  /// await createTableWithAttributes('users', ['name', 'age', 'email']);
  Future<void> createTableWithAttributes(
      String tableName, List<String> attributes) async {
    final db = await database;

    // Convert names to SQL columns (default type = TEXT)
    final columnsSql = attributes.map((attr) => '$attr TEXT').join(', ');

    final sql = '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnsSql
      )
    ''';

    await db.execute(sql);
    print('✅ Table "$tableName" created with columns: id, ${attributes.join(', ')}');
  }

  // ------------------------------------------------------------------
  // 🧩 CRUD OPERATIONS
  // ------------------------------------------------------------------

  /// Insert data into a given table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Get all rows from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'id DESC');
  }

  /// Get a specific record by ID
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Update a record by ID
  Future<int> update(String table, int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete a record by ID
  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all rows from a table
  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
