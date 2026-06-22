import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/pdf_file_entity.dart';
import '../repositories/web_file_bytes_repository.dart';

/// Wraps all direct OS/filesystem interaction: picking files, scanning
/// device storage for PDFs, and performing rename/delete operations.
///
/// Isolating this behind a class means the rest of the app never imports
/// `dart:io` or `file_picker` directly, which keeps platform quirks
/// (especially Web, which has no real filesystem) contained here.
class FileSystemDataSource {
  final _uuid = const Uuid();
  final _webBytes = WebFileBytesRepository();

  /// Best-effort permission request before [scanDeviceForPdfs].
  ///
  /// [FilePicker.platform.pickFiles] (used by [pickPdfFile]) needs no
  /// runtime permission on any supported OS version, since it goes
  /// through the system document/file picker — so this is only relevant
  /// for the "scan device for PDFs" feature, which reads directories
  /// directly.
  ///
  /// On Android 13+ (API 33+), `READ_EXTERNAL_STORAGE` is no longer a
  /// functional permission and there's no general "documents" media
  /// permission — so on those versions this always resolves without a
  /// dialog, and [scanDeviceForPdfs] will only find PDFs already inside
  /// the app's own scoped storage. That's a real platform limitation,
  /// not a bug here.
  Future<bool> ensureStoragePermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted || result.isLimited;
  }

  /// Opens the native file picker restricted to PDF files.
  /// Returns null if the user cancelled.
  ///
  /// On Web, there is no real file path: the picked bytes are persisted
  /// into local (IndexedDB-backed) storage keyed by a generated id, and
  /// that key is stored on the returned entity as [PdfFileEntity.webBytesKey]
  /// so the viewer can look the content back up later (including after
  /// a page reload, since this is real persistent storage, not memory).
  Future<PdfFileEntity?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // Web has no real path; we need bytes instead
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;

    if (kIsWeb) {
      final bytes = picked.bytes;
      if (bytes == null) return null;
      final key = _uuid.v4();
      await _webBytes.save(key, bytes);
      return PdfFileEntity(
        id: _uuid.v4(),
        path: 'web://$key', // virtual identifier; real content is in webBytesKey
        name: p.basenameWithoutExtension(picked.name),
        sizeBytes: picked.size,
        modifiedAt: DateTime.now(),
        webBytesKey: key,
      );
    }

    final file = File(picked.path!);
    final stat = await file.stat();
    return PdfFileEntity(
      id: _uuid.v4(),
      path: picked.path!,
      name: p.basenameWithoutExtension(picked.path!),
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
    );
  }

  /// Recursively scans common document directories for PDF files.
  /// Not supported on Web (no filesystem access) — returns an empty list.
  Future<List<PdfFileEntity>> scanDeviceForPdfs() async {
    if (kIsWeb) return [];

    final dirsToScan = <Directory>[];
    try {
      if (Platform.isAndroid) {
        dirsToScan.add(Directory('/storage/emulated/0/Download'));
        dirsToScan.add(Directory('/storage/emulated/0/Documents'));
      }
      final appDocs = await getApplicationDocumentsDirectory();
      dirsToScan.add(appDocs);
    } catch (_) {
      // ignore directories we cannot resolve
    }

    final found = <PdfFileEntity>[];
    for (final dir in dirsToScan) {
      if (!await dir.exists()) continue;
      try {
        final entities = dir.listSync(recursive: true, followLinks: false);
        for (final entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
            final stat = await entity.stat();
            found.add(PdfFileEntity(
              id: _uuid.v4(),
              path: entity.path,
              name: p.basenameWithoutExtension(entity.path),
              sizeBytes: stat.size,
              modifiedAt: stat.modified,
            ));
          }
        }
      } catch (_) {
        // permission or IO error on this directory; skip it
        continue;
      }
    }
    return found;
  }

  Future<void> deleteFile(String path) async {
    if (kIsWeb) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Renames the file on disk and returns the new full path.
  Future<String> renameFile(String oldPath, String newBaseName) async {
    if (kIsWeb) return oldPath;
    final file = File(oldPath);
    final dir = p.dirname(oldPath);
    final ext = p.extension(oldPath);
    final newPath = p.join(dir, '$newBaseName$ext');
    final renamed = await file.rename(newPath);
    return renamed.path;
  }
}
