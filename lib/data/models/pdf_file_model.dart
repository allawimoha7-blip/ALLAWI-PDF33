import '../../domain/entities/pdf_file_entity.dart';

/// Maps between [PdfFileEntity] and the SQLite row shape used by
/// `recent_files`. Kept separate from the entity so the domain layer
/// has zero knowledge of column names or storage types.
class PdfFileModel {
  static Map<String, Object?> toRow(PdfFileEntity e) => {
        'id': e.id,
        'path': e.path,
        'name': e.name,
        'size_bytes': e.sizeBytes,
        'modified_at': e.modifiedAt.millisecondsSinceEpoch,
        'last_opened_at': e.lastOpenedAt?.millisecondsSinceEpoch,
        'last_page_read': e.lastPageRead,
        'total_pages': e.totalPages,
        'is_password_protected': e.isPasswordProtected ? 1 : 0,
        'thumbnail_path': e.thumbnailPath,
        'web_bytes_key': e.webBytesKey,
      };

  static PdfFileEntity fromRow(Map<String, Object?> row, {bool isFavorite = false}) {
    return PdfFileEntity(
      id: row['id'] as String,
      path: row['path'] as String,
      name: row['name'] as String,
      sizeBytes: row['size_bytes'] as int,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(row['modified_at'] as int),
      lastOpenedAt: row['last_opened_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['last_opened_at'] as int)
          : null,
      isFavorite: isFavorite,
      lastPageRead: row['last_page_read'] as int? ?? 0,
      totalPages: row['total_pages'] as int? ?? 0,
      isPasswordProtected: (row['is_password_protected'] as int? ?? 0) == 1,
      thumbnailPath: row['thumbnail_path'] as String?,
      webBytesKey: row['web_bytes_key'] as String?,
    );
  }
}
