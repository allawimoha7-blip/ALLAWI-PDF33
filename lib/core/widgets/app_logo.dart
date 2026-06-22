import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The ALLAWI PDF Reader logo mark, drawn with [CustomPainter] rather
/// than a bitmap asset.
///
/// Rationale: a vector mark stays crisp at every size (splash screen,
/// app bar, favicon) and at every density without shipping multiple
/// PNG resolutions, and it can react to the live theme color instantly.
/// The shape: a rounded "document" silhouette with a folded corner and
/// a stylized "A" cut from the page — read as both "PDF page" and the
/// app's initial.
class AppLogoMark extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogoMark({super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: color ?? Colors.white),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rrectRadius = w * 0.22;

    // Rounded square backdrop (soft brand-tinted glass card)
    final backdropPaint = Paint()..color = color.withOpacity(0.14);
    final backdropRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(rrectRadius),
    );
    canvas.drawRRect(backdropRect, backdropPaint);

    // Document body
    final docWidth = w * 0.46;
    final docHeight = h * 0.62;
    final docLeft = (w - docWidth) / 2;
    final docTop = (h - docHeight) / 2;
    final foldSize = docWidth * 0.32;

    final docPath = Path()
      ..moveTo(docLeft, docTop)
      ..lineTo(docLeft + docWidth - foldSize, docTop)
      ..lineTo(docLeft + docWidth, docTop + foldSize)
      ..lineTo(docLeft + docWidth, docTop + docHeight)
      ..lineTo(docLeft, docTop + docHeight)
      ..close();

    final docPaint = Paint()..color = color;
    canvas.drawPath(docPath, docPaint);

    // Folded corner accent (brand amber tint to add a premium detail)
    final foldPath = Path()
      ..moveTo(docLeft + docWidth - foldSize, docTop)
      ..lineTo(docLeft + docWidth, docTop + foldSize)
      ..lineTo(docLeft + docWidth - foldSize, docTop + foldSize)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = AppColors.accentAmber);

    // "A" cut-out lines (two diagonals + crossbar) representing the
    // app initial, knocked out of the document using the backdrop tone.
    final linePaint = Paint()
      ..color = color.withOpacity(0.0)
      ..style = PaintingStyle.stroke;
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawPath(docPath, docPaint);
    canvas.drawPath(foldPath, Paint()..color = AppColors.accentAmber);

    final knockoutPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    final aLeft = docLeft + docWidth * 0.18;
    final aRight = docLeft + docWidth * 0.82;
    final aTop = docTop + docHeight * 0.30;
    final aBottom = docTop + docHeight * 0.82;
    final aMidX = (aLeft + aRight) / 2;

    canvas.drawLine(Offset(aMidX, aTop), Offset(aLeft, aBottom), knockoutPaint);
    canvas.drawLine(Offset(aMidX, aTop), Offset(aRight, aBottom), knockoutPaint);
    final barY = aTop + (aBottom - aTop) * 0.62;
    final barHalf = (aMidX - aLeft) * 0.42;
    canvas.drawLine(Offset(aMidX - barHalf, barY), Offset(aMidX + barHalf, barY), knockoutPaint);

    canvas.restore();
    linePaint.color = color;
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => oldDelegate.color != color;
}
