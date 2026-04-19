import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/core/services/notification_scheduler_service.dart';
import 'package:health_care_app/core/services/notification_service.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_history_list_screen.dart';

class MedicineTodayScreen extends StatefulWidget {
  const MedicineTodayScreen({super.key});

  @override
  State<MedicineTodayScreen> createState() => _MedicineTodayScreenState();
}

class _MedicineTodayScreenState extends State<MedicineTodayScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _doses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    // Realtime is already initialized globally in SplashScreen/Login
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getTodayDoses();
      if (mounted) {
        setState(() {
          _doses = data;
          _loading = false;
        });
        // Sync local notifications
        NotificationSchedulerService().scheduleTodayNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _takeDose(
    int scheduleId,
    int scheduleTimeId,
    String status,
  ) async {
    try {
      await _api.takeDose(
        scheduleId: scheduleId,
        scheduleTimeId: scheduleTimeId,
        status: status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'taken' ? 'Obat diminum' : 'Obat dilewati'),
            backgroundColor: status == 'taken' ? Colors.green : Colors.orange,
          ),
        );
      }
      // Cancel the scheduled notification since it's already taken/skipped
      if (status == 'taken' || status == 'skipped') {
        int notificationId = scheduleId * 1000 + scheduleTimeId;
        LocalNotificationService().cancelNotification(notificationId);
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Minum Obat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicineHistoryListScreen(),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (_doses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal obat hari ini',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _doses.length,
        itemBuilder: (context, index) {
          final dose = _doses[index];
          final schedule = dose['schedule'];
          final scheduleTime = dose['schedule_time'];
          final status = dose['status']; // pending, taken, skipped, late

          Color statusColor;
          IconData statusIcon;
          String statusText;

          switch (status) {
            case 'taken':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              statusText = 'Sudah Diminum';
              break;
            case 'skipped':
              statusColor = Colors.orange;
              statusIcon = Icons.cancel;
              statusText = 'Dilewati';
              break;
            case 'late':
              statusColor = Colors.red;
              statusIcon = Icons.warning;
              statusText = 'Terlambat';
              break;
            default: // pending
              statusColor = Colors.blue;
              statusIcon = Icons.access_time;
              statusText = 'Belum Diminum';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatTime(scheduleTime['drink_time']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    schedule['medicine']['name'] ?? 'Obat',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosis: ${schedule['dosage'] ?? '-'} (${schedule['dose_per_intake']} unit)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Catatan: ${_getMealRelation(schedule['meal_relation'])}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),

                  if (status == 'pending' || status == 'late') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _confirmAction(
                              context,
                              schedule['id'],
                              scheduleTime['id'],
                              'skipped',
                              'Yakin ingin melewati dosis ini?',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                            ),
                            child: const Text('Lewati'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmAction(
                              context,
                              schedule['id'],
                              scheduleTime['id'],
                              'taken',
                              'Konfirmasi sudah meminum obat ini? Stok obat akan dipotong.',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Minum Obat'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMealRelation(String? rel) {
    if (rel == 'before') return 'Sebelum Makan';
    if (rel == 'after') return 'Sesudah Makan';
    if (rel == 'with') return 'Saat Makan (Bersamaan)';
    return 'Bebas';
  }

  void _confirmAction(
    BuildContext context,
    int schedId,
    int timeId,
    String status,
    String msg,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'taken' ? Colors.green : Colors.orange,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _takeDose(schedId, timeId, status);
            },
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
  }
}
