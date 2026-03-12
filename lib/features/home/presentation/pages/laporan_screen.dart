import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/presentation/pages/health_check_list_screen.dart';
import 'package:health_care_app/features/health/presentation/pages/vital_sign_list_screen.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Laporan Kesehatan',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.monitor_heart), text: 'Tanda Vital'),
                Tab(icon: Icon(Icons.health_and_safety), text: 'Pemeriksaan'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  VitalSignListScreen(showAppBar: false),
                  HealthCheckListScreen(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
