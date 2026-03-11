import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/auth/presentation/pages/login_screen.dart';
import 'package:health_care_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:health_care_app/core/widgets/metric_card.dart';
import 'package:health_care_app/core/widgets/medication_item.dart';
import 'package:health_care_app/core/widgets/sos_button.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic body based on selected index
    Widget bodyContent;
    switch (_selectedIndex) {
      case 3:
        bodyContent = const ProfileScreen();
        break;
      case 0:
      default:
        bodyContent = _buildHomeContent(theme);
        break;
    }

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildHomeContent(ThemeData theme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            SOSButton(
              onTap: () {
                // Implement SOS action
              },
            ),
            const SizedBox(height: 32),
            Text('Kondisi Kesehatan', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildHealthMetricsGrid(theme),
            const SizedBox(height: 32),
            Text('Jadwal Obat Hari Ini', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildMedicationList(theme),
            const SizedBox(height: 24),
          ],
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
              'Sudahkah Anda berolahraga hari ini?',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout();
            } else if (value == 'profile') {
              setState(() {
                _selectedIndex = 3;
              });
            } else if (value == 'chucker') {
              ChuckerFlutter.showChuckerScreen();
            }
          },
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Profil Saya'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            PopupMenuItem<String>(
              value: 'chucker',
              child: ListTile(
                leading: Icon(
                  Icons.bug_report,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Buka Chucker'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 35,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
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
      children: const [
        MetricCard(
          title: 'Detak Jantung',
          value: '72',
          unit: 'BPM',
          icon: Icons.favorite,
          color: Colors.redAccent,
        ),
        MetricCard(
          title: 'Tekanan Darah',
          value: '120/80',
          unit: 'mmHg',
          icon: Icons.speed,
          color: Colors.blueAccent,
        ),
        MetricCard(
          title: 'Langkah',
          value: '4.250',
          unit: 'Langkah',
          icon: Icons.directions_walk,
          color: Colors.orangeAccent,
        ),
        MetricCard(
          title: 'Gula Darah',
          value: '110',
          unit: 'mg/dL',
          icon: Icons.bloodtype,
          color: Color(0xFF00796B), // tealAccent.shade700
        ),
      ],
    );
  }

  Widget _buildMedicationList(ThemeData theme) {
    return Column(
      children: [
        MedicationItem(
          name: 'Amlodipine',
          time: '08:00 WIB',
          taken: true,
          onTakenPressed: () {},
        ),
        const SizedBox(height: 12),
        MedicationItem(
          name: 'Metformin',
          time: '13:00 WIB',
          taken: false,
          onTakenPressed: () {},
        ),
        const SizedBox(height: 12),
        MedicationItem(
          name: 'Vitamin C',
          time: '19:00 WIB',
          taken: false,
          onTakenPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Jadwal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined_rounded),
          label: 'Laporan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
