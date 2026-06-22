import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/share_helper.dart';
import '../../../domain/entities/pdf_file_entity.dart';
import '../../providers/file_providers.dart';

/// Shared file-card action handlers so Recent/Favorites/All Files tabs
/// don't each reimplement rename/delete/share/favorite dialogs.
class FileActions {
  final WidgetRef ref;
  final BuildContext context;

  FileActions(this.ref, this.context);

  void _refreshAll() {
    ref.invalidate(recentFilesProvider);
    ref.invalidate(favoriteFilesProvider);
    ref.invalidate(allFilesProvider);
  }

  Future<void> openFile(PdfFileEntity file) async {
    final repo = ref.read(pdfFileRepositoryProvider);
    final saved = await repo.upsertOnOpen(file);
    _refreshAll();
    if (context.mounted) context.push('/viewer', extra: saved);
  }

  Future<void> toggleFavorite(PdfFileEntity file) async {
    final repo = ref.read(pdfFileRepositoryProvider);
    await repo.toggleFavorite(file.id, !file.isFavorite);
    _refreshAll();
  }

  Future<void> share(PdfFileEntity file) async {
    if (kIsWeb) return; // no real file path to hand to the OS share sheet on web
    await sharePdfFile(context, path: file.path, text: file.name);
  }

  Future<void> rename(PdfFileEntity file) async {
    final s = context.s;
    final controller = TextEditingController(text: file.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('renameFile')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: s.t('newName')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.t('cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(s.t('save')),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == file.name) return;

    final fs = ref.read(fileSystemDataSourceProvider);
    final repo = ref.read(pdfFileRepositoryProvider);
    try {
      await fs.renameFile(file.path, newName);
    } catch (_) {
      // On web or if the underlying file can't be renamed on disk, we
      // still update the display name in our own records below.
    }
    await repo.rename(file.id, newName);
    _refreshAll();
  }

  Future<void> delete(PdfFileEntity file) async {
    final s = context.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.t('deleteConfirmTitle')),
        content: Text(s.t('deleteConfirmBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.t('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final fs = ref.read(fileSystemDataSourceProvider);
    final repo = ref.read(pdfFileRepositoryProvider);
    await fs.deleteFile(file.path);
    await repo.deleteRecord(file.id);
    _refreshAll();
  }
}
