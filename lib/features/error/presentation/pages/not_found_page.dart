import 'package:flutter/material.dart';
import 'package:health_care_app/features/error/presentation/pages/error_page.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorPage(
      title: 'Halaman Tidak Ditemukan',
      message:
          'Maaf, halaman yang Anda cari tidak dapat ditemukan atau telah dipindahkan.',
      buttonText: 'Kembali ke Beranda',
      onButtonPressed: () =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      icon: Image.asset(
        'assets/images/not_found_illustration.png',
        height: 250,
      ),
    );
  }
}
