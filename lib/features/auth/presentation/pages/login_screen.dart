import 'package:flutter/material.dart';
import 'package:health_care_app/features/home/presentation/pages/dashboard_screen.dart';
import 'package:health_care_app/core/services/reverb_service.dart';
import 'package:health_care_app/core/services/notification_scheduler_service.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_text_field.dart';
import 'package:health_care_app/core/widgets/app_divider.dart';
import 'package:health_care_app/features/auth/presentation/pages/register_screen.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(email, password);

      if (mounted) {
        // Global initialization after login
        ReverbService().init();
        NotificationSchedulerService().scheduleTodayNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, ${response.user.name}!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text('Selamat Datang', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Silakan masuk untuk memantau kesehatan Anda hari ini.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              AppTextField(
                label: 'Email',
                hintText: 'Contoh: budi@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Kata Sandi',
                hintText: 'Masukkan kata sandi Anda',
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
              const SizedBox(height: 40),
              AppButton(
                text: 'Masuk Sekarang',
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?', style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const AppDivider(text: 'Atau'),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Lupa Password akan segera hadir.'),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa kata sandi?',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
