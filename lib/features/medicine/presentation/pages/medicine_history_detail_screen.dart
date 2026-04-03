import 'package:flutter/material.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_history_model.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';

class MedicineHistoryDetailScreen extends StatelessWidget {
  final MedicineHistoryModel history;

  const MedicineHistoryDetailScreen({super.key, required this.history});

  Color _getStatusColor(String? status) {
    if (status == 'consumed') return Colors.green;
    if (status == 'skipped') return Colors.red;
    return Colors.orange;
  }

  IconData _getStatusIcon(String? status) {
    if (status == 'consumed') return Icons.check_circle_outline;
    if (status == 'skipped') return Icons.cancel_outlined;
    return Icons.access_time;
  }

  String _getStatusText(String? status) {
    if (status == 'consumed') return 'Diminum';
    if (status == 'skipped') return 'Dilewati';
    return status ?? 'Terlambat/Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(history.status);
    final schedule = history.medicineSchedule;
    final medicine = schedule?.medicine;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat Dosis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(
                _getStatusIcon(history.status),
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              medicine?.name ?? 'Riwayat',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(history.status),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
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
                          'Waktu Tercatat: ${formatDateTime(history.takenTime ?? history.createdAt ?? '')}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Informasi Jadwal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosis: ${schedule?.dosage ?? '-'}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aturan: ${schedule?.signaFrequency ?? '-'} kali sehari',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instruksi Tambahan: ${schedule?.notes ?? '-'}',
                      style: const TextStyle(fontSize: 15),
                    ),
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
