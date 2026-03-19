import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final String? text;

  const AppDivider({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (text == null) {
      return Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.2));
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text!, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
