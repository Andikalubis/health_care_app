import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/auth/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_divider.dart';
import 'package:health_care_app/features/patient/presentation/pages/patient_data_screen.dart';
import 'package:health_care_app/features/notification/presentation/pages/notification_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Memuat...';
  String _userEmail = '';
  String _userRole = 'user';
  bool _isTelegramIntegrated = false;
  bool _isIntegratingTelegram = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Tamu';
        _userEmail = prefs.getString('user_email') ?? '';
        _userRole = prefs.getString('user_role') ?? 'user';
        // You might want to persist this status or check it from the backend
        _isTelegramIntegrated =
            prefs.getBool('is_telegram_integrated') ?? false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final apiService = ApiService();
    await apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('access_token') == null) {
      await prefs.remove('is_telegram_integrated');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleTelegramIntegration(bool value) async {
    if (value) {
      if (_userEmail.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email user tidak ditemukan')),
          );
        }
        return;
      }

      setState(() => _isIntegratingTelegram = true);

      try {
        final apiService = ApiService();
        final response = await apiService.subscribeLinkByEmail(_userEmail);

        if (response.containsKey('subscribe_url')) {
          final String? subscribeUrl = response['subscribe_url']?.toString();

          if (subscribeUrl != null && subscribeUrl.isNotEmpty) {
            final uri = Uri.parse(subscribeUrl);

            bool launched = false;
            try {
              if (await canLaunchUrl(uri)) {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                // Fallback attempt
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (e) {
              launched = false;
            }

            if (launched) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_telegram_integrated', true);
              if (mounted) setState(() => _isTelegramIntegrated = true);
            } else {
              throw 'Tidak bisa membuka link Telegram';
            }
          } else {
            throw 'Link integrasi kosong';
          }
        } else {
          throw 'Gagal mendapatkan link integrasi dari server';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isIntegratingTelegram = false);
      }
    } else {
      // Logic for disconnecting if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_telegram_integrated', false);
      setState(() => _isTelegramIntegrated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 52,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userName,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text('Akun Personal', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),

            // Patient data & notification menu
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: _userRole == 'admin' ? 'Data Diri' : 'Data Pasien',
                    subtitle: _userRole == 'admin'
                        ? 'Kelola data pribadi Anda'
                        : 'Kelola data kesehatan dasar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: null,
                          body: PatientDataScreenEmbed(
                            forceSelfMode: _userRole == 'admin',
                            title: _userRole == 'admin'
                                ? 'Data Diri'
                                : 'Data Pasien',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const AppDivider(),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    subtitle: 'Riwayat pesan dan peringatan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationListScreen(),
                      ),
                    ),
                  ),
                  const AppDivider(),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    subtitle: 'FAQ dan kontak dukungan',
                    onTap: () {},
                  ),
                  const AppDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.telegram,
                            color: Colors.blue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Integrasi Telegram',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Terima notifikasi via Telegram',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isIntegratingTelegram)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Switch(
                            value: _isTelegramIntegrated,
                            onChanged: _handleTelegramIntegration,
                            activeThumbColor: Colors.blue,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            AppButton(
              text: 'Logout',
              onPressed: _handleLogout,
              icon: Icons.logout,
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
