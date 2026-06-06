import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/home/presentation/pages/jadwal_screen.dart';
import 'package:health_care_app/features/home/presentation/pages/laporan_screen.dart';
import 'package:health_care_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/meal/data/models/meal_schedule_model.dart';
import 'package:health_care_app/features/meal/presentation/pages/meal_schedule_list_screen.dart';
import 'package:health_care_app/features/patient/presentation/pages/patient_data_screen.dart';
import 'package:health_care_app/features/home/presentation/pages/master_data_screen.dart';
import 'package:health_care_app/features/notification/presentation/pages/notification_list_screen.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_today_screen.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/core/services/reverb_service.dart';
import 'package:flutter/foundation.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';

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
  List<MealScheduleModel> _todayMeals = [];
  bool _loadingVital = true;
  bool _loadingMeds = true;
  bool _loadingMeals = true;
  int _unreadCount = 0;

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
      _initRealtime(prefs.getInt('user_id'), _userRole);
    }
  }

  void _initRealtime(int? userId, String role) async {
    final realtime = ReverbService();
    await realtime.init();

    if (userId != null && role != 'admin') {
      // Subscribe to patient specific updates
      realtime.subscribePrivate('patient.$userId', 'vital.updated', (_) {
        if (kDebugMode) print('Dashboard: Vital updated, refreshing...');
        _loadDashboardData();
      });
      realtime.subscribePrivate(
        'patient.$userId',
        'medicine.schedule.updated',
        (_) {
          if (kDebugMode) {
            print('Dashboard: Med schedule updated, refreshing...');
          }
          _loadDashboardData();
        },
      );
      realtime.subscribePrivate('patient.$userId', 'meal.schedule.updated', (
        _,
      ) {
        if (kDebugMode) {
          print('Dashboard: Meal schedule updated, refreshing...');
        }
        _loadDashboardData();
      });
      realtime.subscribePrivate('patient.$userId', 'health.check.updated', (_) {
        if (kDebugMode) {
          print('Dashboard: Health check updated, refreshing...');
        }
        _loadDashboardData();
      });
      realtime.subscribePrivate('patient.$userId', 'medicine.stock.updated', (
        _,
      ) {
        if (kDebugMode) {
          print('Dashboard: Stock updated, refreshing...');
        }
        _loadDashboardData();
      });

      // Subscribe to user notifications
      realtime.subscribePrivate('user.$userId', 'notification.created', (_) {
        if (kDebugMode) print('Dashboard: New notification received!');
        _loadDashboardData(); // Refresh everything including unread count
      });
    }

    if (role == 'admin') {
      realtime.subscribePrivate(
        'admin.dashboard',
        'vital.updated',
        (_) => _loadDashboardData(),
      );
      realtime.subscribePrivate(
        'admin.dashboard',
        'medicine.stock.updated',
        (_) => _loadDashboardData(),
      );
      realtime.subscribePrivate(
        'admin.dashboard',
        'medicine.schedule.updated',
        (_) => _loadDashboardData(),
      );
      realtime.subscribePrivate(
        'admin.dashboard',
        'meal.schedule.updated',
        (_) => _loadDashboardData(),
      );
      realtime.subscribePrivate(
        'admin.dashboard',
        'health.check.updated',
        (_) => _loadDashboardData(),
      );
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

    // Load today's meal schedule
    try {
      final meals = await _api.getTodayMeals();
      if (mounted) {
        setState(() {
          _todayMeals = meals.take(3).toList();
          _loadingMeals = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMeals = false);
    }

    // Load and schedule today's notifications (Now handled by Backend for persistence)
    if (_userRole != 'admin') {
      // Load unread notification count
      try {
        final count = await _api.getUnreadNotificationCount();
        if (mounted) setState(() => _unreadCount = count);
      } catch (_) {}
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
    final pad = ResponsiveHelper.contentPadding(context);
    final sp = ResponsiveHelper.spacing(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              SizedBox(height: sp * 2.5),
              Text('Panel Admin', style: theme.textTheme.displayMedium),
              SizedBox(height: sp * 0.6),
              Text(
                'Selamat datang di pusat pemantauan kesehatan.',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: sp * 2.5),
              _buildAdminQuickActions(theme),
              SizedBox(height: sp * 3.2),
              Text('Ringkasan Pasien', style: theme.textTheme.headlineMedium),
              SizedBox(height: sp * 1.3),
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
    final pad = ResponsiveHelper.contentPadding(context);
    final sp = ResponsiveHelper.spacing(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              SizedBox(height: sp * 2.5),
              // SOSButton(onTap: () {}),
              SizedBox(height: sp * 2.5),
              Text('Kondisi Kesehatan', style: theme.textTheme.headlineMedium),
              SizedBox(height: sp * 1.3),
              _buildHealthMetricsGrid(theme),
              SizedBox(height: sp * 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Obat Hari Ini',
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicineTodayScreen(),
                      ),
                    ),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              SizedBox(height: sp * 1.3),
              _buildMedicationList(theme),
              SizedBox(height: sp * 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Makan Hari Ini',
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MealScheduleListScreen(),
                      ),
                    ),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              SizedBox(height: sp * 1.3),
              _buildMealList(theme),
              SizedBox(height: sp * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final notifSize = ResponsiveHelper.iconSize(context, 54);
    final iconSz = ResponsiveHelper.iconSize(context, 30);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Halo, $_userName!',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tarik layar untuk memperbarui data',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (_userRole != 'admin')
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationListScreen(),
                ),
              );
              _loadDashboardData();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: notifSize,
                  height: notifSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: iconSz,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHealthMetricsGrid(ThemeData theme) {
    final vital = _latestVital;
    final sp = ResponsiveHelper.spacing(context);
    final w = MediaQuery.of(context).size.width;
    final crossAxis = w < 360 ? 1 : 2;
    final aspectRatio = w < 360 ? 1.3 : (w < 600 ? 0.85 : 0.95);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxis,
      mainAxisSpacing: sp,
      crossAxisSpacing: sp,
      childAspectRatio: aspectRatio,
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
    final cm = ResponsiveHelper.cardMargin(context);
    final cr = ResponsiveHelper.cardRadius(context);
    final avatarSz = ResponsiveHelper.avatarRadius(context, 24);
    return Column(
      children: _todayMeds.map((med) {
        return Card(
          margin: EdgeInsets.only(bottom: cm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cr),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: avatarSz,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.medication, color: theme.colorScheme.primary, size: ResponsiveHelper.iconSize(context, 24)),
            ),
            title: Text(
              med.medicine?.name ?? 'Obat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveHelper.fontSize(context, 17)),
            ),
            subtitle: Text(
              '${med.scheduleTimes?.map((t) => formatTime(t.drinkTime ?? '')).join(', ') ?? '-'}  •  ${med.dosage ?? '-'}',
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(context, 15)),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineTodayScreen()),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealList(ThemeData theme) {
    if (_loadingMeals) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_todayMeals.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada jadwal makan',
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
    final cm = ResponsiveHelper.cardMargin(context);
    final cr = ResponsiveHelper.cardRadius(context);
    final avatarSz = ResponsiveHelper.avatarRadius(context, 24);
    return Column(
      children: _todayMeals.map((meal) {
        return Card(
          margin: EdgeInsets.only(bottom: cm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cr),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: avatarSz,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: Icon(Icons.restaurant, color: Colors.orange, size: ResponsiveHelper.iconSize(context, 24)),
            ),
            title: Text(
              meal.mealType?.name ?? 'Makan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveHelper.fontSize(context, 17)),
            ),
            subtitle: Text(
              '${formatTime(meal.mealTime ?? '-')}${meal.notes != null && meal.notes!.isNotEmpty ? '  •  ${meal.notes}' : ''}',
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(context, 15)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.orange),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealScheduleListScreen()),
            ),
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

    final iconSz = ResponsiveHelper.iconSize(context, 28);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      type: BottomNavigationBarType.fixed,
      iconSize: iconSz,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveHelper.fontSize(context, 14),
      ),
      unselectedLabelStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(context, 12)),
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
    final sp = ResponsiveHelper.spacing(context);
    final iconSz = ResponsiveHelper.iconSize(context, 32);
    final cr = ResponsiveHelper.cardRadius(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(cr + 4),
      child: Container(
        padding: EdgeInsets.all(sp * 1.6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(cr + 4),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: iconSz),
            SizedBox(height: sp),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.fontSize(context, 18),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: ResponsiveHelper.fontSize(context, 13),
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
    final sp = ResponsiveHelper.spacing(context);
    final iconSz = ResponsiveHelper.iconSize(context, 36);
    final cr = ResponsiveHelper.cardRadius(context);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(cr),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: EdgeInsets.all(sp * 1.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSz),
          SizedBox(height: sp),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.fontSize(context, 15),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp * 0.5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: ResponsiveHelper.fontSize(context, 28),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            unit,
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: ResponsiveHelper.fontSize(context, 14)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
