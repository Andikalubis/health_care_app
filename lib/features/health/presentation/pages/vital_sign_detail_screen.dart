import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';

class VitalSignDetailScreen extends StatelessWidget {
  final VitalSignModel vital;

  const VitalSignDetailScreen({super.key, required this.vital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tanda Vital')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.monitor_heart, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Pengukuran Tanda Vital',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              formatDateTimeShort(vital.checkTime ?? vital.createdAt),
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (vital.patient != null) ...[
                      _buildRow(
                        Icons.person,
                        'Pasien',
                        vital.patient!.name,
                        Colors.grey,
                      ),
                      const Divider(),
                    ],
                    _buildRow(
                      Icons.speed,
                      'Tekanan Darah',
                      vital.bloodPressure ?? '-',
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.favorite,
                      'Detak Jantung',
                      '${vital.heartRate ?? '-'} BPM',
                      Colors.red,
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.thermostat,
                      'Suhu',
                      '${vital.bodyTemperature ?? '-'} °C',
                      Colors.orange,
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.air,
                      'Laju Pernapasan',
                      '${vital.breathingRate ?? '-'} /m',
                      Colors.teal,
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.bloodtype,
                      'Saturasi O₂',
                      '${vital.oxygenLevel ?? '-'}%',
                      Colors.purple,
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

  Widget _buildRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
