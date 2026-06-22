import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../domain/entities/pdf_file_entity.dart';
import '../../providers/file_providers.dart';
import 'file_actions.dart';
import 'pdf_file_card.dart';

class AllFilesTab extends ConsumerStatefulWidget {
  const AllFilesTab({super.key});

  @override
  ConsumerState<AllFilesTab> createState() => _AllFilesTabState();
}

class _AllFilesTabState extends ConsumerState<AllFilesTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PdfFileEntity> _filterAndSort(List<PdfFileEntity> files, String query, FileSortMode sort) {
    var result = files;
    if (query.isNotEmpty) {
      result = result.where((f) => f.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    final sorted = [...result];
    switch (sort) {
      case FileSortMode.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case FileSortMode.date:
        sorted.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case FileSortMode.size:
        sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final filesAsync = ref.watch(allFilesProvider);
    final query = ref.watch(fileSearchQueryProvider);
    final sortMode = ref.watch(fileSortModeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => ref.read(fileSearchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: s.t('searchFiles'),
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<FileSortMode>(
                initialValue: sortMode,
                onSelected: (mode) => ref.read(fileSortModeProvider.notifier).state = mode,
                icon: const Icon(LucideIcons.arrowUpDown),
                itemBuilder: (context) => [
                  PopupMenuItem(value: FileSortMode.name, child: Text(s.t('name'))),
                  PopupMenuItem(value: FileSortMode.date, child: Text(s.t('date'))),
                  PopupMenuItem(value: FileSortMode.size, child: Text(s.t('size'))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(s.t('noFiles'))),
            data: (files) {
              final visible = _filterAndSort(files, query, sortMode);
              if (visible.isEmpty) {
                return EmptyState(
                  icon: LucideIcons.folderOpen,
                  title: query.isEmpty ? s.t('noFiles') : s.t('noResults'),
                  subtitle: '',
                );
              }
              final actions = FileActions(ref, context);
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(allFilesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final file = visible[i];
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
          ),
        ),
      ],
    );
  }
}
