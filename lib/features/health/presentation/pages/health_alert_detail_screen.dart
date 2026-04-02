import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/data/models/health_alert_model.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';

class HealthAlertDetailScreen extends StatelessWidget {
  final HealthAlertModel alert;

  const HealthAlertDetailScreen({super.key, required this.alert});

  Color _getLevelColor(String? level) {
    if (level == 'danger') return Colors.red;
    if (level == 'warning') return Colors.orange;
    return Colors.blue;
  }

  IconData _getLevelIcon(String? level) {
    if (level == 'danger') return Icons.dangerous;
    if (level == 'warning') return Icons.warning_amber;
    return Icons.info_outline;
  }

  String _getLevelText(String? level) {
    if (level == 'danger') return 'BAHAYA';
    if (level == 'warning') return 'PERINGATAN';
    return 'INFO';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getLevelColor(alert.alertLevel);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Peringatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(
                _getLevelIcon(alert.alertLevel),
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              alert.healthCheck?.patient?.name ?? 'Peringatan #${alert.id}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getLevelText(alert.alertLevel),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDateTime(alert.createdAt ?? ''),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Pesan Peringatan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.message ?? 'Tidak ada pesan.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (alert.healthCheck != null) ...[
                      const Divider(height: 32),
                      const Text(
                        'Data Cek Kesehatan Terkait',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jenis Pemeriksaan: ${alert.healthCheck?.healthType?.name ?? '-'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nilai Hasil: ${alert.healthCheck?.resultValue ?? '-'}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Catatan: ${alert.healthCheck?.notes ?? '-'}',
                        style: const TextStyle(fontSize: 15),
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
}
