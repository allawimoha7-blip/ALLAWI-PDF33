import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/pdf_file_entity.dart';
import '../datasources/app_database.dart';
import '../models/pdf_file_model.dart';
import 'web_file_bytes_repository.dart';

/// Repository owning all persistence for known PDF files: the recent-files
/// list, favorites, and per-file reading progress.
///
/// This is the single integration point the presentation layer talks to —
/// it never sees SQL or row maps, only [PdfFileEntity].
class PdfFileRepository {
  final AppDatabase _db = AppDatabase.instance;
  final WebFileBytesRepository _webBytes = WebFileBytesRepository();

  Future<List<PdfFileEntity>> getRecentFiles({int limit = AppConstants.maxRecentFiles}) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.tableRecentFiles,
      orderBy: 'last_opened_at DESC',
      limit: limit,
    );
    final favoriteIds = await _favoriteIds(db);
    return rows.map((r) => PdfFileModel.fromRow(r, isFavorite: favoriteIds.contains(r['id']))).toList();
  }

  Future<List<PdfFileEntity>> getFavorites() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT rf.* FROM ${AppConstants.tableRecentFiles} rf
      INNER JOIN ${AppConstants.tableFavorites} f ON f.file_id = rf.id
      ORDER BY f.added_at DESC
    ''');
    return rows.map((r) => PdfFileModel.fromRow(r, isFavorite: true)).toList();
  }

  Future<List<PdfFileEntity>> getAllKnownFiles() async {
    final db = await _db.database;
    final rows = await db.query(AppConstants.tableRecentFiles, orderBy: 'name ASC');
    final favoriteIds = await _favoriteIds(db);
    return rows.map((r) => PdfFileModel.fromRow(r, isFavorite: favoriteIds.contains(r['id']))).toList();
  }

  Future<Set<String>> _favoriteIds(Database db) async {
    final rows = await db.query(AppConstants.tableFavorites, columns: ['file_id']);
    return rows.map((r) => r['file_id'] as String).toSet();
  }

  /// Inserts the file if new, or updates `last_opened_at` if it already
  /// exists (matched by file path, since the same file may be re-opened
  /// via different picker calls but should not duplicate).
  Future<PdfFileEntity> upsertOnOpen(PdfFileEntity file) async {
    final db = await _db.database;
    final existing = await db.query(
      AppConstants.tableRecentFiles,
      where: 'path = ?',
      whereArgs: [file.path],
      limit: 1,
    );

    final now = DateTime.now();
    if (existing.isNotEmpty) {
      final existingId = existing.first['id'] as String;
      await db.update(
        AppConstants.tableRecentFiles,
        {'last_opened_at': now.millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [existingId],
      );
      final favoriteIds = await _favoriteIds(db);
      return PdfFileModel.fromRow(
        {...existing.first, 'last_opened_at': now.millisecondsSinceEpoch},
        isFavorite: favoriteIds.contains(existingId),
      );
    } else {
      final toInsert = file.copyWith(lastOpenedAt: now);
      await db.insert(AppConstants.tableRecentFiles, PdfFileModel.toRow(toInsert),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return toInsert;
    }
  }

  Future<void> updateProgress(String fileId, int lastPage, int totalPages) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableRecentFiles,
      {'last_page_read': lastPage, 'total_pages': totalPages},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  Future<void> updateMeta(String fileId, {int? totalPages, bool? isPasswordProtected}) async {
    final db = await _db.database;
    final values = <String, Object?>{};
    if (totalPages != null) values['total_pages'] = totalPages;
    if (isPasswordProtected != null) values['is_password_protected'] = isPasswordProtected ? 1 : 0;
    if (values.isEmpty) return;
    await db.update(AppConstants.tableRecentFiles, values, where: 'id = ?', whereArgs: [fileId]);
  }

  Future<void> rename(String fileId, String newName) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableRecentFiles,
      {'name': newName},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  Future<void> deleteRecord(String fileId) async {
    final db = await _db.database;
    if (kIsWeb) {
      final existing = await db.query(AppConstants.tableRecentFiles, where: 'id = ?', whereArgs: [fileId], limit: 1);
      final key = existing.isNotEmpty ? existing.first['web_bytes_key'] as String? : null;
      if (key != null) await _webBytes.delete(key);
    }
    await db.delete(AppConstants.tableRecentFiles, where: 'id = ?', whereArgs: [fileId]);
    await db.delete(AppConstants.tableFavorites, where: 'file_id = ?', whereArgs: [fileId]);
    await db.delete(AppConstants.tableBookmarks, where: 'file_id = ?', whereArgs: [fileId]);
    await db.delete(AppConstants.tableAnnotations, where: 'file_id = ?', whereArgs: [fileId]);
  }

  Future<void> toggleFavorite(String fileId, bool isFavorite) async {
    final db = await _db.database;
    if (isFavorite) {
      await db.insert(
        AppConstants.tableFavorites,
        {'file_id': fileId, 'added_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(AppConstants.tableFavorites, where: 'file_id = ?', whereArgs: [fileId]);
    }
  }
}
