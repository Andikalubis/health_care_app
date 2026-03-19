import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(text);

    ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: width != null ? Size(width!, 56) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    if (icon != null && !isLoading) {
      return SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: Icon(icon),
          label: Text(text),
          style: style,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
