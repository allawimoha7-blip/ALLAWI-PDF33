import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/theme/app_colors.dart';

/// Side drawer showing a scrollable grid of page thumbnails so the user
/// can jump straight to any page.
///
/// Takes the already-loaded [PdfDocument] (captured by the parent screen
/// in `PdfViewerParams.onViewerReady`) rather than re-opening the file
/// itself — this avoids loading the PDF twice and keeps memory/CPU usage
/// low even for large documents. Each thumbnail renders via [PdfPageView],
/// which is a lightweight, independently-cached render of a single page.
class ThumbnailDrawer extends StatelessWidget {
  final PdfDocument document;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const ThumbnailDrawer({
    super.key,
    required this.document,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageCount = document.pages.length;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(right: BorderSide(color: isDark ? AppColors.darkOutline : AppColors.lightOutline)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: pageCount,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          final isActive = pageNumber == currentPage;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onPageSelected(pageNumber),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? AppColors.brand : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 0.72,
                        child: PdfPageView(
                          document: document,
                          pageNumber: pageNumber,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pageNumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? AppColors.brand : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
