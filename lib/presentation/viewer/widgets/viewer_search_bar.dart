import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/localization/app_strings.dart';

/// Replaces the normal viewer app bar while searching: a text field plus
/// match counter and prev/next navigation, mirroring familiar
/// "find in document" UX from desktop PDF readers.
class ViewerSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final PdfTextSearcher textSearcher;
  final VoidCallback onClose;

  const ViewerSearchBar({super.key, required this.textSearcher, required this.onClose});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ViewerSearchBar> createState() => _ViewerSearchBarState();
}

class _ViewerSearchBarState extends State<ViewerSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final searcher = widget.textSearcher;
    final hasMatches = searcher.hasMatches;
    final matchLabel = hasMatches
        ? '${(searcher.currentIndex ?? 0) + 1}/${searcher.matches.length}'
        : '';

    return AppBar(
      titleSpacing: 0,
      title: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: s.t('searchInDocument'),
          border: InputBorder.none,
        ),
        onChanged: (query) => searcher.startTextSearch(query),
      ),
      actions: [
        if (hasMatches) Center(child: Padding(padding: const EdgeInsets.only(right: 8), child: Text(matchLabel))),
        IconButton(
          icon: const Icon(LucideIcons.chevronUp),
          onPressed: hasMatches ? () => searcher.goToPrevMatch() : null,
        ),
        IconButton(
          icon: const Icon(LucideIcons.chevronDown),
          onPressed: hasMatches ? () => searcher.goToNextMatch() : null,
        ),
        IconButton(icon: const Icon(LucideIcons.x), onPressed: widget.onClose),
      ],
    );
  }
}
