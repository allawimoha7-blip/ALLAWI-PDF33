import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../providers/file_providers.dart';
import 'file_actions.dart';
import 'pdf_file_card.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final filesAsync = ref.watch(favoriteFilesProvider);

    return filesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(s.t('noFavorites'))),
      data: (files) {
        if (files.isEmpty) {
          return EmptyState(
            icon: LucideIcons.star,
            title: s.t('noFavorites'),
            subtitle: s.t('noFavoritesSub'),
          );
        }
        final actions = FileActions(ref, context);
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(favoriteFilesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: files.length,
            itemBuilder: (context, i) {
              final file = files[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PdfFileCard(
                  file: file,
                  animationIndex: i,
                  onTap: () => actions.openFile(file),
                  onToggleFavorite: () => actions.toggleFavorite(file),
                  onRename: () => actions.rename(file),
                  onDelete: () => actions.delete(file),
                  onShare: () => actions.share(file),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
