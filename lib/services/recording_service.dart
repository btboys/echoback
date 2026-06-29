import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/recording.dart';

class RecordingService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'echoback.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recordings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filePath TEXT NOT NULL,
            fileName TEXT NOT NULL,
            durationMs INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            hasAccompaniment INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insert(Recording recording) async {
    final db = await database;
    return db.insert('recordings', recording.toMap()..remove('id'));
  }

  Future<List<Recording>> getAll() async {
    final db = await database;
    final maps = await db.query('recordings', orderBy: 'createdAt DESC');
    return maps.map((m) => Recording.fromMap(m)).toList();
  }

  Future<Recording?> get(int id) async {
    final db = await database;
    final maps = await db.query('recordings', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Recording.fromMap(maps.first);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('recordings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Recording recording) async {
    final db = await database;
    return db.update('recordings', recording.toMap(),
        where: 'id = ?', whereArgs: [recording.id]);
  }
}
