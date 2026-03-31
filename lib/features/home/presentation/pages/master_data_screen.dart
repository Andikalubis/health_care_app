import 'package:flutter/material.dart';
import 'package:health_care_app/features/notification/presentation/pages/master_notification_list_screen.dart';
import 'package:health_care_app/features/health/presentation/pages/health_type_list_screen.dart';
import 'package:health_care_app/features/meal/presentation/pages/meal_type_list_screen.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_list_screen.dart';
import 'package:health_care_app/features/health/presentation/pages/health_limit_list_screen.dart';
import 'package:health_care_app/features/patient/presentation/pages/patient_data_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _userRole = prefs.getString('user_role') ?? 'user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kelola Data Master',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildMasterItem(
                  theme,
                  title: 'Jenis Pemeriksaan',
                  subtitle: 'Kelola kategori pemeriksaan kesehatan',
                  icon: Icons.health_and_safety_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HealthTypeListScreen(),
                      ),
                    );
                  },
                ),
                _buildMasterItem(
                  theme,
                  title: 'Jenis Makanan',
                  subtitle: 'Kelola kategori jadwal makan',
                  icon: Icons.restaurant_menu_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MealTypeListScreen(),
                      ),
                    );
                  },
                ),
                _buildMasterItem(
                  theme,
                  title: 'Daftar Obat',
                  subtitle: 'Kelola data obat-obatan',
                  icon: Icons.medication_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicineListScreen(),
                      ),
                    );
                  },
                ),
                _buildMasterItem(
                  theme,
                  title: 'Batas Kesehatan',
                  subtitle: 'Atur ambang batas tanda vital',
                  icon: Icons.assignment_late_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HealthLimitListScreen(),
                      ),
                    );
                  },
                ),
                _buildMasterItem(
                  theme,
                  title: 'Master Notifikasi',
                  subtitle: 'Kelola template notifikasi sistem',
                  icon: Icons.notifications_active_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MasterNotificationListScreen(),
                      ),
                    );
                  },
                ),
                if (_userRole == 'admin')
                  _buildMasterItem(
                    theme,
                    title: 'Daftar Pasien',
                    subtitle: 'Kelola data seluruh pasien',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientDataScreenEmbed(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterItem(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
