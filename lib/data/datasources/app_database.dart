import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_web;
import '../../core/constants/app_constants.dart';

/// Single source of truth for the app's local SQLite database.
///
/// Handles platform differences transparently:
/// - On Android/iOS/desktop: standard `sqflite`.
/// - On Web: `sqflite_common_ffi_web`, which persists via IndexedDB.
///
/// All repositories go through this class rather than opening their own
/// connections, so schema changes / migrations live in exactly one place.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    DatabaseFactory factory;
    String dbPath;

    if (kIsWeb) {
      factory = sqflite_web.databaseFactoryFfiWeb;
      dbPath = AppConstants.dbName;
    } else {
      factory = databaseFactory;
      final dir = await getApplicationDocumentsDirectory();
      dbPath = p.join(dir.path, AppConstants.dbName);
    }

    return factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableRecentFiles} (
        id TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        name TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        last_opened_at INTEGER,
        last_page_read INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        is_password_protected INTEGER NOT NULL DEFAULT 0,
        thumbnail_path TEXT,
        web_bytes_key TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableFavorites} (
        file_id TEXT PRIMARY KEY,
        added_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableBookmarks} (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        label TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableAnnotations} (
        id TEXT PRIMARY KEY,
        file_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        type TEXT NOT NULL,
        text TEXT,
        color_hex TEXT NOT NULL DEFAULT '#F2A33D',
        stroke_points TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableReadingProgress} (
        file_id TEXT PRIMARY KEY,
        last_page_read INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Web has no real filesystem, so picked PDF bytes are persisted here
    // (IndexedDB-backed via sqflite_common_ffi_web) keyed by a generated
    // id, rather than by a real file path as on Android/iOS/desktop.
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWebFileBytes} (
        key TEXT PRIMARY KEY,
        bytes BLOB NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_bookmarks_file ON ${AppConstants.tableBookmarks}(file_id)');
    await db.execute('CREATE INDEX idx_annotations_file ON ${AppConstants.tableAnnotations}(file_id)');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}

/// Thin helper to check file existence safely (web has no [File] access,
/// so callers must guard with [kIsWeb] before touching this).
bool fileExistsSync(String path) {
  if (kIsWeb) return true;
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
