import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/auth/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_app/core/widgets/app_button.dart';
import 'package:health_care_app/core/widgets/app_divider.dart';

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
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Tamu';
      });
    }
  }

  Future<void> _handleLogout() async {
    final apiService = ApiService();
    await apiService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// PROFILE HEADER
            Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text('Akun Personal', style: theme.textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 32),

            /// MENU CARD
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
                    title: 'Edit Profil',
                    onTap: () {},
                  ),

                  const AppDivider(),

                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Aplikasi',
                    onTap: () {},
                  ),

                  const AppDivider(),

                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// LOGOUT BUTTON
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
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
