import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildSOSButton(theme),
              const SizedBox(height: 32),
              Text(
                'Kondisi Kesehatan',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildHealthMetricsGrid(theme),
              const SizedBox(height: 32),
              Text(
                'Jadwal Obat Hari Ini',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildMedicationList(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Bapak Budi!',
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              'Sudahkah Anda berolahraga hari ini?',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.person, size: 35, color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildSOSButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Text(
            'DARURAT / SOS',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildMetricCard(
          theme,
          title: 'Detak Jantung',
          value: '72',
          unit: 'BPM',
          icon: Icons.favorite,
          color: Colors.redAccent,
        ),
        _buildMetricCard(
          theme,
          title: 'Tekanan Darah',
          value: '120/80',
          unit: 'mmHg',
          icon: Icons.speed,
          color: Colors.blueAccent,
        ),
        _buildMetricCard(
          theme,
          title: 'Langkah',
          value: '4.250',
          unit: 'Langkah',
          icon: Icons.directions_walk,
          color: Colors.orangeAccent,
        ),
        _buildMetricCard(
          theme,
          title: 'Gula Darah',
          value: '110',
          unit: 'mg/dL',
          icon: Icons.bloodtype,
          color: Colors.tealAccent.shade700,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 24, color: theme.colorScheme.onSurface),
              ),
              Text(unit, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(ThemeData theme) {
    return Column(
      children: [
        _buildMedicationItem(theme, name: 'Amlodipine', time: '08:00 WIB', taken: true),
        const SizedBox(height: 12),
        _buildMedicationItem(theme, name: 'Metformin', time: '13:00 WIB', taken: false),
        const SizedBox(height: 12),
        _buildMedicationItem(theme, name: 'Vitamin C', time: '19:00 WIB', taken: false),
      ],
    );
  }

  Widget _buildMedicationItem(ThemeData theme, {required String name, required String time, required bool taken}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: taken ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: taken ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: taken ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              color: taken ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(time, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (taken)
            const Icon(Icons.check_circle, color: Colors.green, size: 30)
          else
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Minum'),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
      showSecondaryAnimations: true,
      type: BottomNavigationBarType.fixed,
      iconSize: 32,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
        BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined_rounded), label: 'Laporan'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Profil'),
      ],
    );
  }
}
