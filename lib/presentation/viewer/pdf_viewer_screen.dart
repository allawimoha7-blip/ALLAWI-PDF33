import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_helper.dart';
import '../../data/repositories/web_file_bytes_repository.dart';
import '../../domain/entities/pdf_file_entity.dart';
import '../providers/file_providers.dart';
import '../providers/reader_settings_providers.dart';
import 'widgets/bookmarks_sheet.dart';
import 'widgets/page_indicator.dart';
import 'widgets/password_dialog.dart';
import 'widgets/thumbnail_drawer.dart';
import 'widgets/viewer_search_bar.dart';
import 'widgets/viewer_top_bar.dart';

/// The PDF reading screen — the heart of the app.
///
/// Composition over one giant widget: the page surface is [PdfViewer],
/// and the app/search/bottom bars + thumbnail drawer are separate
/// widgets so this file stays focused on orchestration (state, page
/// tracking, persistence) rather than layout.
class PdfViewerScreen extends ConsumerStatefulWidget {
  final PdfFileEntity file;
  const PdfViewerScreen({super.key, required this.file});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late final PdfViewerController _controller;
  late final PdfTextSearcher _textSearcher;

  bool _isSearching = false;
  bool _showThumbnails = false;
  int _currentPage = 1;
  int _totalPages = 0;
  PdfDocument? _document;
  int _passwordAttempt = 0;
  Uint8List? _webBytes;
  bool _webBytesLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _textSearcher = PdfTextSearcher(_controller)..addListener(_onSearchUpdate);
    _currentPage = (widget.file.lastPageRead > 0 ? widget.file.lastPageRead : 1);
    if (kIsWeb && widget.file.webBytesKey != null) {
      _webBytesLoading = true;
      WebFileBytesRepository().load(widget.file.webBytesKey!).then((bytes) {
        if (!mounted) return;
        setState(() {
          _webBytes = bytes;
          _webBytesLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _textSearcher.removeListener(_onSearchUpdate);
    _textSearcher.dispose();
    super.dispose();
  }

  void _onSearchUpdate() {
    if (mounted) setState(() {});
  }

  void _onPageChanged(int? page) {
    if (page == null) return;
    setState(() => _currentPage = page);
    // Auto-save last page read on every page change — cheap, debounced
    // implicitly by how often the user actually flips pages.
    ref.read(pdfFileRepositoryProvider).updateProgress(widget.file.id, page, _totalPages);
  }

  Future<String?> _passwordProvider() async {
    final s = context.s;
    // pdfrx calls this once per attempt; show an error message starting
    // on the second call (the first call is the user's initial attempt).
    final errorText = _passwordAttempt > 0 ? s.t('wrongPassword') : null;
    _passwordAttempt++;
    if (!mounted) return null;
    final result = await showPasswordDialog(context, errorText: errorText, title: s.t('enterPassword'));
    if (result != null) {
      await ref.read(pdfFileRepositoryProvider).updateMeta(widget.file.id, isPasswordProtected: true);
    }
    return result;
  }

  Future<void> _shareFile() async {
    if (kIsWeb) {
      // Web has no real file path to hand to the OS share sheet; sharing
      // bytes directly is a possible future enhancement but out of scope
      // for this screen's current responsibilities.
      return;
    }
    await sharePdfFile(context, path: widget.file.path, text: widget.file.name);
  }

  Future<void> _printFile() async {
    if (kIsWeb) return;
    // Printing is delegated to the OS share sheet / print dialog: most
    // platforms' "Print" appears as a target inside native share, and
    // a dedicated `printing` package call can be wired in here later
    // without changing this screen's public surface.
    await sharePdfFile(context, path: widget.file.path, text: 'Print: ${widget.file.name}');
  }

  PdfViewerParams _viewerParams(AppStrings s) {
    return PdfViewerParams(
      pagePaintCallbacks: [_textSearcher.pageTextMatchPaintCallback],
      onViewerReady: (document, controller) async {
        final total = document.pages.length;
        if (!mounted) return;
        setState(() {
          _totalPages = total;
          _document = document;
        });
        await ref
            .read(pdfFileRepositoryProvider)
            .updateMeta(widget.file.id, totalPages: total, isPasswordProtected: false);
        // Resume at the last-read page, if any, once the document and
        // its layout are actually ready.
        if (widget.file.lastPageRead > 1 && widget.file.lastPageRead <= total) {
          controller.goToPage(pageNumber: widget.file.lastPageRead);
        }
      },
      onPageChanged: _onPageChanged,
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(s.t('loadingDocument')),
          ],
        ),
      ),
    );
  }

  /// Builds the actual page-rendering widget.
  ///
  /// On Android/iOS/desktop, [PdfFileEntity.path] is a real file path, so
  /// [PdfViewer.file] reads directly from disk. On Web there is no
  /// filesystem: the picked PDF's bytes were persisted separately (see
  /// [FileSystemDataSource.pickPdfFile]) and are loaded asynchronously
  /// in [initState], so this renders a loading state until they're ready
  /// and then uses [PdfViewer.data].
  Widget _buildPdfViewer(AppStrings s) {
    if (kIsWeb) {
      if (_webBytesLoading) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(s.t('loadingDocument')),
            ],
          ),
        );
      }
      final bytes = _webBytes;
      if (bytes == null) {
        return Center(child: Text(s.t('noFiles')));
      }
      return PdfViewer.data(
        bytes,
        sourceName: widget.file.name,
        controller: _controller,
        passwordProvider: () => _passwordProvider(),
        params: _viewerParams(s),
      );
    }

    return PdfViewer.file(
      widget.file.path,
      controller: _controller,
      passwordProvider: () => _passwordProvider(),
      params: _viewerParams(s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isFullScreen = ref.watch(isFullScreenProvider);
    final visualMode = ref.watch(readerVisualModeProvider);

    final bgColor = switch (visualMode) {
      ReaderVisualMode.night => AppColors.nightReadingBg,
      ReaderVisualMode.sepia => AppColors.sepiaReadingBg,
      ReaderVisualMode.normal => Theme.of(context).scaffoldBackgroundColor,
    };

    final PreferredSizeWidget? viewerAppBar = isFullScreen
        ? null
        : (_isSearching
            ? ViewerSearchBar(
                textSearcher: _textSearcher,
                onClose: () {
                  setState(() => _isSearching = false);
                  _textSearcher.resetTextSearch();
                },
              )
            : ViewerTopBar(
                file: widget.file,
                onSearch: () => setState(() => _isSearching = true),
                onShare: _shareFile,
                onPrint: _printFile,
                onThumbnails: () => setState(() => _showThumbnails = !_showThumbnails),
                onBookmarks: () => showBookmarksSheet(context, ref, widget.file, _currentPage, (page) {
                  _controller.goToPage(pageNumber: page);
                }),
              ));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: viewerAppBar,
      body: SafeArea(
        top: isFullScreen,
        child: Stack(
          children: [
            Row(
              children: [
                if (_showThumbnails && !isFullScreen && _document != null)
                  ThumbnailDrawer(
                    document: _document!,
                    currentPage: _currentPage,
                    onPageSelected: (page) {
                      _controller.goToPage(pageNumber: page);
                      setState(() => _showThumbnails = false);
                    },
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isFullScreen) {
                        ref.read(isFullScreenProvider.notifier).state = false;
                      }
                    },
                    child: ColorFiltered(
                      // pdfrx renders pages as opaque white bitmaps, so a
                      // night/sepia "theme" can't be done via background
                      // color alone — this filter tints the actual
                      // rendered page content. BlendMode.dst is a no-op
                      // (normal mode); BlendMode.difference inverts
                      // luminance for a low-glare dark reading tone.
                      colorFilter: ColorFilter.mode(
                        visualMode == ReaderVisualMode.night
                            ? Colors.white
                            : (visualMode == ReaderVisualMode.sepia ? AppColors.sepiaReadingBg : Colors.transparent),
                        visualMode == ReaderVisualMode.night
                            ? BlendMode.difference
                            : (visualMode == ReaderVisualMode.sepia ? BlendMode.multiply : BlendMode.dst),
                      ),
                      child: _buildPdfViewer(s),
                    ),
                  ),
                ),
              ],
            ),
            if (!isFullScreen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PageIndicatorBar(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onJumpToPage: (page) => _controller.goToPage(pageNumber: page),
                  onToggleFullScreen: () => ref.read(isFullScreenProvider.notifier).state = true,
                  onToggleNightMode: () {
                    final notifier = ref.read(readerVisualModeProvider.notifier);
                    notifier.setMode(visualMode == ReaderVisualMode.night
                        ? ReaderVisualMode.normal
                        : ReaderVisualMode.night);
                  },
                  isNightMode: visualMode == ReaderVisualMode.night,
                ),
              ),
            if (isFullScreen)
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    icon: const Icon(LucideIcons.minimize2),
                    onPressed: () => ref.read(isFullScreenProvider.notifier).state = false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
