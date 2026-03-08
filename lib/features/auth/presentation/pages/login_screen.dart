import 'package:flutter/material.dart';
import 'package:health_care_app/features/home/presentation/pages/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
                    color: theme.colorScheme.primary.withOpacity(0.1),
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
              Text(
                'Email',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Contoh: budi@email.com',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Kata Sandi',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi Anda',
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
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                child: const Text('Masuk Sekarang'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Atau', style: theme.textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
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
    );
  }
}
