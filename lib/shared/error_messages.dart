import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showErrorSnack(BuildContext ctx, String text) {
  ScaffoldMessenger.of(ctx).clearSnackBars();
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Theme.of(ctx).colorScheme.onPrimaryContainer),
      ),
      duration: const Duration(milliseconds: 800),
      backgroundColor: Theme.of(ctx).colorScheme.primaryContainer,
    ),
  );
}

void showErrordialog(BuildContext ctx, String title, String text) {
  showDialog(
    context: ctx,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}
