import 'package:flutter/cupertino.dart';

/// Native alert with a single OK button (or custom actions).
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  String? message,
  List<CupertinoDialogAction>? actions,
}) {
  return showCupertinoDialog<void>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions:
          actions ??
          [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
    ),
  );
}

/// Native confirm alert; resolves true when the destructive action is chosen.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String actionLabel,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
