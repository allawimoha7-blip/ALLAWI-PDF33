import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/localization/app_strings.dart';
import '../providers/file_providers.dart';
import 'widgets/all_files_tab.dart';
import 'widgets/favorites_tab.dart';
import 'widgets/recent_tab.dart';

/// Root shell after splash: bottom-navigation between Recent, Favorites,
/// and All Files, plus a floating action button to open a new PDF.
///
/// Tab state lives locally (not in the router) since these are siblings
/// of one logical "home" destination rather than separately deep-linkable
/// pages — keeps navigation simple while still using go_router for the
/// screens that do deserve their own route (viewer, settings).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final tabs = [
      const RecentTab(),
      const FavoritesTab(),
      const AllFilesTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('appName')),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: s.t('settings'),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFile(context),
        icon: const Icon(LucideIcons.filePlus2),
        label: Text(s.t('openFile')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(LucideIcons.clock), label: s.t('recent')),
          NavigationDestination(icon: const Icon(LucideIcons.star), label: s.t('favorites')),
          NavigationDestination(icon: const Icon(LucideIcons.folder), label: s.t('files')),
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    final fs = ref.read(fileSystemDataSourceProvider);
    // The native file picker (Storage Access Framework on Android,
    // document picker on iOS) needs no runtime permission, so it's
    // launched directly — no permission gate here.
    final picked = await fs.pickPdfFile();
    if (picked == null) return;

    final repo = ref.read(pdfFileRepositoryProvider);
    final saved = await repo.upsertOnOpen(picked);

    ref.invalidate(recentFilesProvider);
    ref.invalidate(allFilesProvider);

    if (context.mounted) {
      context.push('/viewer', extra: saved);
    }
  }
}
