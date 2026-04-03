import 'package:flutter/material.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/features/patient/presentation/pages/medical_record_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final PatientDataModel patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pasien')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              patient.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              patient.gender == 'male' ? 'Laki-laki' : 'Perempuan',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicalRecordScreen(
                        patientId: patient.id!,
                        patientName: patient.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text('Lihat Rekam Medis'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.cake_outlined,
              'Tanggal Lahir',
              patient.birthDate,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.bloodtype_outlined,
              'Golongan Darah',
              patient.bloodType ?? '-',
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.height,
                    'Tinggi',
                    '${patient.height ?? '-'} cm',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.monitor_weight_outlined,
                    'Berat',
                    '${patient.weight ?? '-'} kg',
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              Icons.phone_outlined,
              'No. Telepon',
              patient.noTlp ?? '-',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.telegram,
              'Telegram ID',
              patient.telegramId ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
