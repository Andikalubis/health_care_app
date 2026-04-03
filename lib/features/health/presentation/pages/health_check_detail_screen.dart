import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'add_health_check_screen.dart';

class HealthCheckDetailScreen extends StatelessWidget {
  final HealthCheckModel check;
  final String userRole;

  const HealthCheckDetailScreen({
    super.key,
    required this.check,
    required this.userRole,
  });

  Color _statusColor(String? s) {
    if (s == 'danger') return Colors.red;
    if (s == 'warning') return Colors.orange;
    return Colors.green;
  }

  IconData _statusIcon(String? s) {
    if (s == 'danger') return Icons.dangerous;
    if (s == 'warning') return Icons.warning;
    return Icons.check_circle;
  }

  String _statusLabel(String? s) {
    if (s == 'danger') return 'Bahaya';
    if (s == 'warning') return 'Peringatan';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(check.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pemeriksaan'),
        actions: [
          if (userRole != 'admin')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddHealthCheckScreen(existing: check),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(_statusIcon(check.status), size: 56, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              check.healthType?.name ?? 'Pemeriksaan #${check.id}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _statusLabel(check.status),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person_outline,
                      'Pasien',
                      check.patient?.name ?? 'Tidak diketahui',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.monitor_heart_outlined,
                      'Hasil Pemeriksaan',
                      '${check.resultValue ?? '-'} ${check.healthType?.unit ?? ''}',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.event_outlined,
                      'Waktu',
                      formatDateTimeShort(check.checkTime ?? check.createdAt),
                    ),
                    if (check.notes != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        Icons.notes_outlined,
                        'Catatan',
                        check.notes!,
                      ),
                    ],
                  ],
                ),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
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
