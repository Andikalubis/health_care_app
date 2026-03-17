import 'package:flutter/material.dart';
import 'package:health_care_app/core/theme/app_theme.dart';
import 'package:health_care_app/core/widgets/app_button.dart';

class ErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? icon;

  const ErrorPage({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBackground, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 32),
            ] else ...[
              const Icon(
                Icons.error_outline_rounded,
                size: 100,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 32),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.darkBackground,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (buttonText != null && onButtonPressed != null)
              AppButton(text: buttonText!, onPressed: onButtonPressed!),
          ],
        ),
      ),
    );
  }
}
