import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';

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

    final sp = ResponsiveHelper.spacing(context);
    final cr = ResponsiveHelper.cardRadius(context);
    return Container(
      padding: EdgeInsets.all(sp * 1.3),
      decoration: BoxDecoration(
        color: taken
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(cr),
        border: Border.all(
          color: taken
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sp * 0.8),
            decoration: BoxDecoration(
              color: taken
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              size: ResponsiveHelper.iconSize(context, 24),
              color: taken
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(width: sp),
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
            Icon(Icons.check_circle, color: Colors.green, size: ResponsiveHelper.iconSize(context, 30))
          else
            OutlinedButton(
              onPressed: onTakenPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cr - 4),
                ),
              ),
              child: const Text('Minum'),
            ),
        ],
      ),
    );
  }
}
