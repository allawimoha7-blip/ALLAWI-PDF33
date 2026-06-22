import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/app_database.dart';

/// Stores raw PDF bytes for the Web platform, where there is no real
/// filesystem to hold a file path. Backed by the same SQLite database
/// (IndexedDB under the hood on Web via sqflite_common_ffi_web), so a
/// picked PDF survives a page refresh just like on native platforms.
///
/// Not used on Android/iOS/desktop — those read PDFs directly from disk.
class WebFileBytesRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> save(String key, Uint8List bytes) async {
    final db = await _db.database;
    await db.insert(
      AppConstants.tableWebFileBytes,
      {'key': key, 'bytes': bytes},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Uint8List?> load(String key) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.tableWebFileBytes,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['bytes'];
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return null;
  }

  Future<void> delete(String key) async {
    final db = await _db.database;
    await db.delete(AppConstants.tableWebFileBytes, where: 'key = ?', whereArgs: [key]);
  }
}
