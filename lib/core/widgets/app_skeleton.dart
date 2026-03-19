import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool isCircle;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.margin,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);
    final highlightColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF5F5F5);

    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: isCircle
                ? BorderRadius.circular(height)
                : BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
