import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Centralizes calls to the native share sheet.
///
/// iOS 26 throws a platform exception if [ShareParams.sharePositionOrigin]
/// is left at its zero default, so every call site provides a small
/// non-zero fallback rect rather than each caller having to remember
/// this platform quirk individually.
Future<void> sharePdfFile(BuildContext context, {required String path, String? text}) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null
      ? box.localToGlobal(Offset.zero) & box.size
      : const Rect.fromLTWH(0, 0, 1, 1);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(path)],
      text: text,
      sharePositionOrigin: origin,
    ),
  );
}
