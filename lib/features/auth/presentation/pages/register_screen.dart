import 'package:flutter/material.dart';
import 'package:health_care_app/features/home/presentation/pages/dashboard_screen.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_text_field.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kata sandi tidak cocok')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.register(
        name,
        email,
        password,
        confirmPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pendaftaran berhasil, selamat datang ${response.user.name}!',
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daftar Akun Baru', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Mulai perjalanan kesehatan Anda bersama kami.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              AppTextField(
                label: 'Nama Lengkap',
                hintText: 'Contoh: Budi Santoso',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Email',
                hintText: 'budisantoso@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Kata Sandi',
                hintText: 'Buat kata sandi aman',
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Konfirmasi Kata Sandi',
                hintText: 'Ulangi kata sandi Anda',
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                prefixIcon: const Icon(Icons.lock_clock_outlined),
              ),
              const SizedBox(height: 48),
              AppButton(
                text: 'Daftar Sekarang',
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun?', style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ChuckerFlutter.showChuckerScreen();
        },
        tooltip: 'Buka Chucker',
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}
