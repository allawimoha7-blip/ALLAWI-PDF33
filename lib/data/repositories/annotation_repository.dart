import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/bookmark_entity.dart';
import '../datasources/app_database.dart';

/// Repository for in-document bookmarks and annotations (highlights,
/// notes, freehand drawings). Kept separate from [PdfFileRepository]
/// since these scale per-page rather than per-file and have very
/// different query patterns.
class AnnotationRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  // ---------- Bookmarks ----------

  Future<List<BookmarkEntity>> getBookmarks(String fileId) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.tableBookmarks,
      where: 'file_id = ?',
      whereArgs: [fileId],
      orderBy: 'page_number ASC',
    );
    return rows
        .map((r) => BookmarkEntity(
              id: r['id'] as String,
              fileId: r['file_id'] as String,
              pageNumber: r['page_number'] as int,
              label: r['label'] as String?,
              createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
            ))
        .toList();
  }

  Future<BookmarkEntity> addBookmark(String fileId, int pageNumber, {String? label}) async {
    final db = await _db.database;
    final entity = BookmarkEntity(
      id: _uuid.v4(),
      fileId: fileId,
      pageNumber: pageNumber,
      label: label,
      createdAt: DateTime.now(),
    );
    await db.insert(AppConstants.tableBookmarks, {
      'id': entity.id,
      'file_id': entity.fileId,
      'page_number': entity.pageNumber,
      'label': entity.label,
      'created_at': entity.createdAt.millisecondsSinceEpoch,
    });
    return entity;
  }

  Future<void> removeBookmark(String id) async {
    final db = await _db.database;
    await db.delete(AppConstants.tableBookmarks, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isPageBookmarked(String fileId, int pageNumber) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.tableBookmarks,
      where: 'file_id = ? AND page_number = ?',
      whereArgs: [fileId, pageNumber],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ---------- Annotations ----------

  Future<List<AnnotationEntity>> getAnnotations(String fileId, {int? pageNumber}) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.tableAnnotations,
      where: pageNumber != null ? 'file_id = ? AND page_number = ?' : 'file_id = ?',
      whereArgs: pageNumber != null ? [fileId, pageNumber] : [fileId],
      orderBy: 'page_number ASC, created_at ASC',
    );
    return rows.map(_annotationFromRow).toList();
  }

  Future<AnnotationEntity> addAnnotation({
    required String fileId,
    required int pageNumber,
    required AnnotationType type,
    String? text,
    String colorHex = '#F2A33D',
    List<List<double>>? strokePoints,
  }) async {
    final db = await _db.database;
    final entity = AnnotationEntity(
      id: _uuid.v4(),
      fileId: fileId,
      pageNumber: pageNumber,
      type: type,
      text: text,
      colorHex: colorHex,
      strokePoints: strokePoints,
      createdAt: DateTime.now(),
    );
    await db.insert(AppConstants.tableAnnotations, {
      'id': entity.id,
      'file_id': entity.fileId,
      'page_number': entity.pageNumber,
      'type': entity.type.name,
      'text': entity.text,
      'color_hex': entity.colorHex,
      'stroke_points': entity.strokePoints != null ? jsonEncode(entity.strokePoints) : null,
      'created_at': entity.createdAt.millisecondsSinceEpoch,
    });
    return entity;
  }

  Future<void> removeAnnotation(String id) async {
    final db = await _db.database;
    await db.delete(AppConstants.tableAnnotations, where: 'id = ?', whereArgs: [id]);
  }

  AnnotationEntity _annotationFromRow(Map<String, Object?> r) {
    List<List<double>>? strokes;
    final raw = r['stroke_points'] as String?;
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      strokes = decoded.map((e) => (e as List).map((v) => (v as num).toDouble()).toList()).toList();
    }
    return AnnotationEntity(
      id: r['id'] as String,
      fileId: r['file_id'] as String,
      pageNumber: r['page_number'] as int,
      type: AnnotationType.values.firstWhere((t) => t.name == r['type']),
      text: r['text'] as String?,
      colorHex: r['color_hex'] as String? ?? '#F2A33D',
      strokePoints: strokes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
    );
  }
}
