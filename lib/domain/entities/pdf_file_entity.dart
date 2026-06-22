import 'package:equatable/equatable.dart';

/// Domain entity representing a PDF file known to the app.
///
/// This is intentionally decoupled from any database/storage row shape —
/// the data layer maps to/from this entity so the presentation layer
/// never depends on persistence details.
///
/// [path] is a real filesystem path on Android/iOS/desktop. On Web there
/// is no filesystem, so [path] holds a stable virtual identifier instead
/// and the actual content lives in [webBytesKey] — a key the viewer uses
/// to look up the file's bytes from local storage (IndexedDB-backed),
/// since browsers don't expose persistent file paths.
class PdfFileEntity extends Equatable {
  final String id;
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modifiedAt;
  final DateTime? lastOpenedAt;
  final bool isFavorite;
  final int lastPageRead;
  final int totalPages;
  final bool isPasswordProtected;
  final String? thumbnailPath;
  final String? webBytesKey;

  const PdfFileEntity({
    required this.id,
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.modifiedAt,
    this.lastOpenedAt,
    this.isFavorite = false,
    this.lastPageRead = 0,
    this.totalPages = 0,
    this.isPasswordProtected = false,
    this.thumbnailPath,
    this.webBytesKey,
  });

  double get readingProgress => totalPages == 0 ? 0 : (lastPageRead / totalPages).clamp(0, 1);

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  PdfFileEntity copyWith({
    String? path,
    String? name,
    int? sizeBytes,
    DateTime? modifiedAt,
    DateTime? lastOpenedAt,
    bool? isFavorite,
    int? lastPageRead,
    int? totalPages,
    bool? isPasswordProtected,
    String? thumbnailPath,
    String? webBytesKey,
  }) {
    return PdfFileEntity(
      id: id,
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPageRead: lastPageRead ?? this.lastPageRead,
      totalPages: totalPages ?? this.totalPages,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      webBytesKey: webBytesKey ?? this.webBytesKey,
    );
  }

  @override
  List<Object?> get props => [
        id,
        path,
        name,
        sizeBytes,
        modifiedAt,
        lastOpenedAt,
        isFavorite,
        lastPageRead,
        totalPages,
        isPasswordProtected,
        thumbnailPath,
        webBytesKey,
      ];
}
