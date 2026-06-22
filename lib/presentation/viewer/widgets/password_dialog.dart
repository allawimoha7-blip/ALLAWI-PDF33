import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/localization/app_strings.dart';

/// Shown when [PdfViewer]'s `passwordProvider` is invoked because the
/// document is encrypted. Returns the entered password, or null if the
/// user cancels (in which case pdfrx will stop trying to open the file).
Future<String?> showPasswordDialog(BuildContext context, {String? errorText, required String title}) {
  final controller = TextEditingController();
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final s = context.s;
      return AlertDialog(
        title: Row(children: [
          const Icon(LucideIcons.lock, size: 20),
          const SizedBox(width: 10),
          Text(title),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.t('passwordProtected'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: s.t('enterPassword'),
                errorText: errorText,
              ),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(s.t('cancel'))),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(s.t('unlock'))),
        ],
      );
    },
  );
}
