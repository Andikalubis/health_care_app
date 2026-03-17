import 'package:flutter/material.dart';
import 'package:health_care_app/features/error/presentation/pages/error_page.dart';

class ServerErrorPage extends StatelessWidget {
  const ServerErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorPage(
      title: 'Kesalahan Server',
      message:
          'Terjadi kesalahan pada server kami. Silakan coba lagi beberapa saat lagi.',
      buttonText: 'Coba Lagi',
      onButtonPressed: () => Navigator.of(context).pop(),
      icon: Image.asset(
        'assets/images/server_error_illustration.png',
        height: 250,
      ),
    );
  }
}
