import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/auth/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_divider.dart';
import 'package:health_care_app/features/patient/presentation/pages/patient_data_screen.dart';
import 'package:health_care_app/features/notification/presentation/pages/notification_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _userName = prefs.getString('user_name') ?? 'Tamu');
    }
  }

  Future<void> _handleLogout() async {
    final apiService = ApiService();
    await apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('access_token') == null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
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
                    title: 'Data Pasien',
                    subtitle: 'Kelola data kesehatan dasar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          appBar: null,
                          body: PatientDataScreenEmbed(),
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

/// Embedded patient data screen (no Scaffold wrap)
class PatientDataScreenEmbed extends StatelessWidget {
  const PatientDataScreenEmbed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Pasien',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: const PatientDataScreen(),
    );
  }
}
