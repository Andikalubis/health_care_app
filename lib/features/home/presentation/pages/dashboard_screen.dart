import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/home/presentation/pages/jadwal_screen.dart';
import 'package:health_care_app/features/home/presentation/pages/laporan_screen.dart';
import 'package:health_care_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/patient/presentation/pages/patient_data_screen.dart';
import 'package:health_care_app/features/home/presentation/pages/master_data_screen.dart';
import 'package:health_care_app/features/notification/presentation/pages/notification_list_screen.dart';
// import 'package:health_care_app/core/widgets/sos_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Memuat...';
  String _userRole = 'user';
  final _api = ApiService();

  VitalSignModel? _latestVital;
  List<MedicineScheduleModel> _todayMeds = [];
  bool _loadingVital = true;
  bool _loadingMeds = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboardData();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Tamu';
        _userRole = prefs.getString('user_role') ?? 'user';
      });
    }
  }

  Future<void> _loadDashboardData() async {
    // Load latest vital sign
    try {
      final vitals = await _api.getVitalSigns();
      if (mounted && vitals.isNotEmpty) {
        setState(() {
          _latestVital = vitals.first;
          _loadingVital = false;
        });
      } else {
        if (mounted) setState(() => _loadingVital = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingVital = false);
    }

    // Load today's medication schedule
    try {
      final meds = await _api.getMedicineSchedules();
      if (mounted) {
        setState(() {
          _todayMeds = meds.take(3).toList();
          _loadingMeds = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMeds = false);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bodyContent;
    switch (_selectedIndex) {
      case 1:
        bodyContent = _userRole == 'admin'
            ? const PatientDataScreen()
            : const JadwalScreen();
        break;
      case 2:
        bodyContent = _userRole == 'admin'
            ? const MasterDataScreen()
            : const LaporanScreen();
        break;
      case 3:
        bodyContent = const ProfileScreen();
        break;
      case 0:
      default:
        bodyContent = _userRole == 'admin'
            ? _buildAdminHomeContent(theme)
            : _buildHomeContent(theme);
        break;
    }

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildAdminHomeContent(ThemeData theme) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              Text('Panel Admin', style: theme.textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Selamat datang di pusat pemantauan kesehatan.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              _buildAdminQuickActions(theme),
              const SizedBox(height: 40),
              Text('Ringkasan Pasien', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _buildAdminStatsGrid(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Pasien',
            subtitle: 'Monitoring Data',
            icon: Icons.people_outline,
            onTap: () => setState(() => _selectedIndex = 1),
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            title: 'Master',
            subtitle: 'Kelola Data',
            icon: Icons.storage_rounded,
            onTap: () => setState(() => _selectedIndex = 2),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminStatsGrid(ThemeData theme) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.show_chart, color: theme.colorScheme.primary),
            ),
            title: const Text('Lihat Semua Laporan'),
            subtitle: const Text(
              'Pantau perkembangan kesehatan seluruh pasien',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent(ThemeData theme) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              // SOSButton(onTap: () {}),
              const SizedBox(height: 32),
              Text('Kondisi Kesehatan', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _buildHealthMetricsGrid(theme),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Obat Hari Ini',
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMedicationList(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
              'Halo, $_userName!',
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              'Tarik layar untuk memperbarui data',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationListScreen()),
            );
          },
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsGrid(ThemeData theme) {
    final vital = _latestVital;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _MetricCard(
          title: 'Detak Jantung',
          value: _loadingVital ? '...' : (vital?.heartRate?.toString() ?? '-'),
          unit: 'BPM',
          icon: Icons.favorite,
          color: Colors.redAccent,
        ),
        _MetricCard(
          title: 'Tekanan Darah',
          value: _loadingVital ? '...' : (vital?.bloodPressure ?? '-'),
          unit: 'mmHg',
          icon: Icons.speed,
          color: Colors.blueAccent,
        ),
        _MetricCard(
          title: 'Saturasi O₂',
          value: _loadingVital
              ? '...'
              : (vital?.oxygenLevel?.toString() ?? '-'),
          unit: '%',
          icon: Icons.bloodtype,
          color: const Color(0xFF00796B),
        ),
        _MetricCard(
          title: 'Suhu Tubuh',
          value: _loadingVital
              ? '...'
              : (vital?.bodyTemperature?.toString() ?? '-'),
          unit: '°C',
          icon: Icons.thermostat,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMedicationList(ThemeData theme) {
    if (_loadingMeds) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_todayMeds.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada jadwal obat',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Tambah Jadwal'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: _todayMeds.map((med) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.medication, color: theme.colorScheme.primary),
            ),
            title: Text(
              med.medicine?.name ?? 'Obat',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: Text(
              '${med.drinkTime ?? '-'}  •  ${med.dosage ?? '-'}',
              style: const TextStyle(fontSize: 15),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
            onTap: () => setState(() => _selectedIndex = 1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_rounded),
        label: 'Beranda',
      ),
    ];

    if (_userRole == 'admin') {
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Pasien',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_suggest_rounded),
          label: 'Master',
        ),
      ]);
    } else {
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Jadwal',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined_rounded),
          label: 'Laporan',
        ),
      ]);
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_rounded),
        label: 'Profil',
      ),
    );

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      type: BottomNavigationBarType.fixed,
      iconSize: 32,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      items: items,
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Internal metric card widget ────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
