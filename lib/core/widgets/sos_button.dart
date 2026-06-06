import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SOSButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = ResponsiveHelper.spacing(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.cardRadius(context) + 4),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sp * 1.6),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(ResponsiveHelper.cardRadius(context) + 4),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: ResponsiveHelper.iconSize(context, 36),
            ),
            SizedBox(width: sp),
            Text(
              'DARURAT / SOS',
              style: GoogleFonts.outfit(
                fontSize: ResponsiveHelper.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
