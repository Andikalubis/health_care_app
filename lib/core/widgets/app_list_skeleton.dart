import 'package:flutter/material.dart';
import 'app_skeleton.dart';

class AppListSkeleton extends StatelessWidget {
  final int itemCount;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const AppListSkeleton({
    super.key,
    this.itemCount = 5,
    this.height = 100,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : spacing),
        child: AppSkeleton(
          width: double.infinity,
          height: height,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
