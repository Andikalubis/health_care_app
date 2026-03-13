import 'package:flutter/material.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

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
                  onTap: () {},
                ),
                _buildMasterItem(
                  theme,
                  title: 'Jenis Makanan',
                  subtitle: 'Kelola kategori jadwal makan',
                  icon: Icons.restaurant_menu_outlined,
                  onTap: () {},
                ),
                _buildMasterItem(
                  theme,
                  title: 'Daftar Obat',
                  subtitle: 'Kelola data obat-obatan',
                  icon: Icons.medication_outlined,
                  onTap: () {},
                ),
                _buildMasterItem(
                  theme,
                  title: 'Batas Kesehatan',
                  subtitle: 'Atur ambang batas tanda vital',
                  icon: Icons.assignment_late_outlined,
                  onTap: () {},
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
