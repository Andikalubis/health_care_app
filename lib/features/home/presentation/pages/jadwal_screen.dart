import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/responsive_helper.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_schedule_list_screen.dart';
import 'package:health_care_app/features/meal/presentation/pages/meal_schedule_list_screen.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = ResponsiveHelper.contentPadding(context);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Jadwal Harian',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: ResponsiveHelper.fontSize(context, 26)),
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(context) * 1.3),
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
