import 'package:flutter/material.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_schedule_list_screen.dart';
import 'package:health_care_app/features/meal/presentation/pages/meal_schedule_list_screen.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

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
                  'Jadwal Harian',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.medication), text: 'Obat'),
                Tab(icon: Icon(Icons.restaurant), text: 'Makan'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  MedicineScheduleListScreen(showAppBar: false),
                  MealScheduleListScreen(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
