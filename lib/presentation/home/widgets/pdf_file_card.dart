import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/pdf_file_entity.dart';

/// A polished list-item card representing a single PDF file.
///
/// Shows a document glyph, name, metadata line, an optional reading
/// progress bar, and a trailing favorite star + overflow menu. Used
/// identically across Recent / Favorites / All Files for visual
/// consistency.
class PdfFileCard extends StatelessWidget {
  final PdfFileEntity file;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final int animationIndex;

  const PdfFileCard({
    super.key,
    required this.file,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.brand.withOpacity(isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(LucideIcons.fileText, color: AppColors.brand, size: 26),
                    if (file.isPasswordProtected)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(LucideIcons.lock, size: 9, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file.formattedSize} · ${_formattedDate(file.modifiedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (file.totalPages > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: file.readingProgress,
                          minHeight: 4,
                          backgroundColor: AppColors.lightOutline.withOpacity(isDark ? 0.3 : 1),
                          valueColor: const AlwaysStoppedAnimation(AppColors.accentTeal),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  file.isFavorite ? Icons.star_rounded : LucideIcons.star,
                  color: file.isFavorite ? AppColors.accentAmber : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: onToggleFavorite,
              ),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                    case 'share':
                      onShare();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(children: [
                      const Icon(LucideIcons.share2, size: 18),
                      const SizedBox(width: 10),
                      Text(s.t('share')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(children: [
                      const Icon(LucideIcons.pencil, size: 18),
                      const SizedBox(width: 10),
                      Text(s.t('rename')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
                      const SizedBox(width: 10),
                      Text(s.t('delete'), style: const TextStyle(color: AppColors.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (animationIndex * 40).ms)
        .fadeIn(duration: 280.ms)
        .moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
  }

  String _formattedDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
