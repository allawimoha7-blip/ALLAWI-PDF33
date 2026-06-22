import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/file_system_datasource.dart';
import '../../data/repositories/annotation_repository.dart';
import '../../data/repositories/pdf_file_repository.dart';
import '../../domain/entities/pdf_file_entity.dart';

final pdfFileRepositoryProvider = Provider<PdfFileRepository>((ref) => PdfFileRepository());
final annotationRepositoryProvider = Provider<AnnotationRepository>((ref) => AnnotationRepository());
final fileSystemDataSourceProvider = Provider<FileSystemDataSource>((ref) => FileSystemDataSource());

/// Async list of recently opened files, refreshed via [ref.invalidate].
final recentFilesProvider = FutureProvider<List<PdfFileEntity>>((ref) async {
  return ref.watch(pdfFileRepositoryProvider).getRecentFiles();
});

final favoriteFilesProvider = FutureProvider<List<PdfFileEntity>>((ref) async {
  return ref.watch(pdfFileRepositoryProvider).getFavorites();
});

final allFilesProvider = FutureProvider<List<PdfFileEntity>>((ref) async {
  final repo = ref.watch(pdfFileRepositoryProvider);
  final fs = ref.watch(fileSystemDataSourceProvider);
  final known = await repo.getAllKnownFiles();
  await fs.ensureStoragePermission();
  final onDevice = await fs.scanDeviceForPdfs();

  // Merge: prefer the known record (carries progress/favorite state) for
  // any path already tracked; add device-found files not yet tracked.
  final knownPaths = known.map((f) => f.path).toSet();
  final merged = [...known, ...onDevice.where((f) => !knownPaths.contains(f.path))];
  merged.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return merged;
});

/// Current search query for the file list / file manager screen.
final fileSearchQueryProvider = StateProvider<String>((ref) => '');

/// Current sort mode for the "All Files" tab.
enum FileSortMode { name, date, size }

final fileSortModeProvider = StateProvider<FileSortMode>((ref) => FileSortMode.date);
