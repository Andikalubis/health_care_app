import 'package:flutter/material.dart';
import 'package:health_care_app/features/home/presentation/pages/dashboard_screen.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_text_field.dart';
import 'package:health_care_app/core/widgets/app_divider.dart';
import 'package:health_care_app/features/auth/presentation/pages/register_screen.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan kata sandi harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(username, password);

      if (mounted) {
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
    final pad = ResponsiveHelper.contentPadding(context);
    final iconSz = ResponsiveHelper.iconSize(context, 80);
    final sp = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sp * 1.6),
              Center(
                child: Container(
                  padding: EdgeInsets.all(sp * 1.3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: iconSz,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: sp * 3.2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Selamat Datang', style: theme.textTheme.displayLarge),
              ),
              SizedBox(height: sp * 0.6),
              Text(
                'Silakan masuk untuk memantau kesehatan Anda hari ini.',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: sp * 4),
              AppTextField(
                label: 'Username',
                hintText: 'Contoh: budi123',
                controller: _usernameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              SizedBox(height: sp * 2),
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
              SizedBox(height: sp * 3.2),
              AppButton(
                text: 'Masuk Sekarang',
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              SizedBox(height: sp * 2.5),
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
                        fontSize: ResponsiveHelper.fontSize(context, 18),
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp * 2),
              const AppDivider(text: 'Atau'),
              SizedBox(height: sp * 2),
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
                      fontSize: ResponsiveHelper.fontSize(context, 18),
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
    );
  }
}
