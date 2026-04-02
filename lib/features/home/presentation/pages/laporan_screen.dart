import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/presentation/pages/health_check_list_screen.dart';
import 'package:health_care_app/features/health/presentation/pages/vital_sign_list_screen.dart';
import 'package:health_care_app/features/health/presentation/pages/health_alert_list_screen.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/features/patient/presentation/pages/medical_record_screen.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _api = ApiService();
  PatientDataModel? _patient;
  bool _loadingPatient = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final patients = await _api.getPatientData();
      if (mounted) {
        setState(() {
          _patient = patients.firstWhere((p) => p.userId == userId);
          _loadingPatient = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Laporan Kesehatan',
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
                  ),
                  if (!_loadingPatient && _patient != null)
                    IconButton(
                      icon: const Icon(Icons.assignment_ind_outlined),
                      tooltip: 'Ringkasan Rekam Medis',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicalRecordScreen(
                              patientId: _patient!.id!,
                              patientName: _patient!.name,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.monitor_heart), text: 'Tanda Vital'),
                Tab(icon: Icon(Icons.health_and_safety), text: 'Pemeriksaan'),
                Tab(icon: Icon(Icons.warning_amber), text: 'Peringatan'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  VitalSignListScreen(showAppBar: false),
                  HealthCheckListScreen(showAppBar: false),
                  HealthAlertListScreen(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
