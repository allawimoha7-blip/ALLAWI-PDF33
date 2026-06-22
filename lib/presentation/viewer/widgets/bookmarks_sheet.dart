import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bookmark_entity.dart';
import '../../../domain/entities/pdf_file_entity.dart';
import '../../providers/file_providers.dart';

/// Opens a bottom sheet listing all bookmarks for [file], with the
/// ability to add a bookmark for the current page or jump to / remove
/// an existing one.
Future<void> showBookmarksSheet(
  BuildContext context,
  WidgetRef ref,
  PdfFileEntity file,
  int currentPage,
  ValueChanged<int> onJump,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BookmarksSheetContent(
      file: file,
      currentPage: currentPage,
      onJump: onJump,
    ),
  );
}

class _BookmarksSheetContent extends ConsumerStatefulWidget {
  final PdfFileEntity file;
  final int currentPage;
  final ValueChanged<int> onJump;

  const _BookmarksSheetContent({required this.file, required this.currentPage, required this.onJump});

  @override
  ConsumerState<_BookmarksSheetContent> createState() => _BookmarksSheetContentState();
}

class _BookmarksSheetContentState extends ConsumerState<_BookmarksSheetContent> {
  List<BookmarkEntity> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(annotationRepositoryProvider);
    final list = await repo.getBookmarks(widget.file.id);
    if (mounted) setState(() {
      _bookmarks = list;
      _loading = false;
    });
  }

  Future<void> _addBookmarkForCurrentPage() async {
    final repo = ref.read(annotationRepositoryProvider);
    await repo.addBookmark(widget.file.id, widget.currentPage);
    _load();
  }

  Future<void> _remove(BookmarkEntity b) async {
    final repo = ref.read(annotationRepositoryProvider);
    await repo.removeBookmark(b.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final alreadyBookmarked = _bookmarks.any((b) => b.pageNumber == widget.currentPage);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.t('bookmarks'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  FilledButton.tonalIcon(
                    onPressed: alreadyBookmarked ? null : _addBookmarkForCurrentPage,
                    icon: const Icon(LucideIcons.bookmarkPlus, size: 18),
                    label: Text(s.t('addBookmark')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookmarks.isEmpty
                        ? Center(
                            child: Text(
                              s.t('noResults'),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _bookmarks.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final b = _bookmarks[index];
                              return ListTile(
                                leading: const Icon(LucideIcons.bookmark, color: AppColors.accentAmber),
                                title: Text('${s.t('page')} ${b.pageNumber}'),
                                onTap: () {
                                  widget.onJump(b.pageNumber);
                                  Navigator.pop(context);
                                },
                                trailing: IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
                                  onPressed: () => _remove(b),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
