import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../domain/entities/pdf_file_entity.dart';
import '../../providers/file_providers.dart';

/// Standard (non-search, non-fullscreen) app bar for the viewer screen.
/// Exposes the most-used actions directly as icons and the rest behind
/// a single overflow menu to avoid crowding the bar on small phones.
class ViewerTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final PdfFileEntity file;
  final VoidCallback onSearch;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onThumbnails;
  final VoidCallback onBookmarks;

  const ViewerTopBar({
    super.key,
    required this.file,
    required this.onSearch,
    required this.onShare,
    required this.onPrint,
    required this.onThumbnails,
    required this.onBookmarks,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    return AppBar(
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(icon: const Icon(LucideIcons.search), tooltip: s.t('searchInDocument'), onPressed: onSearch),
        IconButton(icon: const Icon(LucideIcons.layoutGrid), tooltip: s.t('thumbnails'), onPressed: onThumbnails),
        IconButton(icon: const Icon(LucideIcons.bookmark), tooltip: s.t('bookmarks'), onPressed: onBookmarks),
        PopupMenuButton<String>(
          icon: const Icon(LucideIcons.moreVertical),
          onSelected: (value) {
            switch (value) {
              case 'share':
                onShare();
                break;
              case 'print':
                onPrint();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(children: [const Icon(LucideIcons.share2, size: 18), const SizedBox(width: 10), Text(s.t('share'))]),
            ),
            PopupMenuItem(
              value: 'print',
              child: Row(children: [const Icon(LucideIcons.printer, size: 18), const SizedBox(width: 10), Text(s.t('print'))]),
            ),
          ],
        ),
      ],
    );
  }
}
