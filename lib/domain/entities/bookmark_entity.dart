import 'package:equatable/equatable.dart';

/// A bookmarked page within a specific PDF file.
class BookmarkEntity extends Equatable {
  final String id;
  final String fileId;
  final int pageNumber;
  final String? label;
  final DateTime createdAt;

  const BookmarkEntity({
    required this.id,
    required this.fileId,
    required this.pageNumber,
    this.label,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fileId, pageNumber, label, createdAt];
}

/// Type of in-document annotation.
enum AnnotationType { highlight, note, drawing }

/// A highlight, note, or freehand drawing anchored to a page.
class AnnotationEntity extends Equatable {
  final String id;
  final String fileId;
  final int pageNumber;
  final AnnotationType type;
  final String? text; // note content or highlighted text snippet
  final String colorHex;
  final List<List<double>>? strokePoints; // for drawings: list of [x,y] paths flattened per stroke
  final DateTime createdAt;

  const AnnotationEntity({
    required this.id,
    required this.fileId,
    required this.pageNumber,
    required this.type,
    this.text,
    this.colorHex = '#F2A33D',
    this.strokePoints,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fileId, pageNumber, type, text, colorHex, strokePoints, createdAt];
}
