import 'package:flutter/material.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';

class MedicineScheduleDetailScreen extends StatelessWidget {
  final MedicineScheduleModel schedule;

  const MedicineScheduleDetailScreen({super.key, required this.schedule});

  String _mealText(String? code) {
    if (code == 'before') return 'Sebelum Makan';
    if (code == 'after') return 'Sesudah Makan';
    if (code == 'with') return 'Saat Makan';
    return 'Bebas';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Jadwal Obat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.medication, size: 56, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              schedule.medicine?.name ?? 'Obat #${schedule.medicineId}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (schedule.dosage != null)
              Text(
                'Dosis Kandungan: ${schedule.dosage}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
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
                    _buildRow(
                      Icons.repeat,
                      'Frekuensi / Hari',
                      '${schedule.signaFrequency ?? '-'}x Sehari',
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.local_drink,
                      'Dosis / Minum',
                      '${schedule.dosePerIntake ?? '-'} unit',
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.restaurant,
                      'Keterangan Makan',
                      _mealText(schedule.mealRelation),
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.inventory_2,
                      'Total Qty Dibawa',
                      '${schedule.qtyTotal ?? '-'}',
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.shopping_basket,
                      'Sisa Stok Obat',
                      '${schedule.qtyRemaining ?? '-'} (Realtime)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (schedule.scheduleTimes != null &&
                schedule.scheduleTimes!.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Waktu Minum Obat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: schedule.scheduleTimes!.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              formatTime(t.drinkTime ?? ''),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          );
                        }).toList(),
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

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
