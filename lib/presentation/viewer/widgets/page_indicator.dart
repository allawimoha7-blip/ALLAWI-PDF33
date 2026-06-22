import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom overlay bar shown during normal (non-fullscreen) reading.
/// Shows "page X of Y" with a draggable progress slider, plus quick
/// toggles for full-screen and night reading mode.
class PageIndicatorBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onJumpToPage;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onToggleNightMode;
  final bool isNightMode;

  const PageIndicatorBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onJumpToPage,
    required this.onToggleFullScreen,
    required this.onToggleNightMode,
    required this.isNightMode,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalPages == 0 ? 0.0 : currentPage / totalPages;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withOpacity(0.96),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(isNightMode ? LucideIcons.sun : LucideIcons.moon, size: 20),
              onPressed: onToggleNightMode,
              tooltip: s.t('nightMode'),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: progress.clamp(0, 1),
                      onChanged: totalPages == 0
                          ? null
                          : (value) => onJumpToPage((value * totalPages).round().clamp(1, totalPages)),
                    ),
                  ),
                  Text(
                    totalPages == 0 ? '' : '${s.t('page')} $currentPage ${s.t('of')} $totalPages',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.maximize2, size: 20),
              onPressed: onToggleFullScreen,
              tooltip: s.t('fullScreen'),
            ),
          ],
        ),
      ),
    );
  }
}
