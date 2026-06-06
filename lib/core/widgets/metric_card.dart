import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sp = ResponsiveHelper.spacing(context);
    final cr = ResponsiveHelper.cardRadius(context);
    final iconSz = ResponsiveHelper.iconSize(context, 28);
    return Container(
      padding: EdgeInsets.all(sp * 1.3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(cr + 4),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(sp * 0.6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSz),
          ),
          SizedBox(height: sp),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: ResponsiveHelper.fontSize(context, 16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: ResponsiveHelper.fontSize(context, 24),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                unit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveHelper.fontSize(context, 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
