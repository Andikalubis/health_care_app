import 'package:flutter/material.dart';

class MedicationItem extends StatelessWidget {
  final String name;
  final String time;
  final bool taken;
  final VoidCallback? onTakenPressed;

  const MedicationItem({
    super.key,
    required this.name,
    required this.time,
    required this.taken,
    this.onTakenPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: taken
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: taken
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: taken
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              color: taken
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(time, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (taken)
            const Icon(Icons.check_circle, color: Colors.green, size: 30)
          else
            OutlinedButton(
              onPressed: onTakenPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Minum'),
            ),
        ],
      ),
    );
  }
}
