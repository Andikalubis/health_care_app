import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'add_medicine_schedule_screen.dart';

class MedicineScheduleListScreen extends StatefulWidget {
  final bool showAppBar;
  const MedicineScheduleListScreen({super.key, this.showAppBar = true});

  @override
  State<MedicineScheduleListScreen> createState() =>
      _MedicineScheduleListScreenState();
}

class _MedicineScheduleListScreenState
    extends State<MedicineScheduleListScreen> {
  final _api = ApiService();
  List<MedicineScheduleModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getMedicineSchedules();
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
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

  Future<void> _delete(int id) async {
    try {
      await _api.deleteMedicineSchedule(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Jadwal Obat'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMedicineScheduleScreen(),
            ),
          );
          if (ok == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _items.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  widget.showAppBar ? 16 : 80,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => _buildCard(_items[i], theme),
              ),
            ),
    );
  }

  Widget _buildCard(MedicineScheduleModel item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.medication,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicine?.name ?? 'Obat #${item.medicineId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.dosage != null)
                    Text(
                      'Dosis: ${item.dosage}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  if (item.drinkTime != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.drinkTime!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  if (item.startDate != null || item.endDate != null)
                    Text(
                      '${item.startDate ?? '?'} s/d ${item.endDate ?? '?'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  if (item.notes != null)
                    Text(
                      item.notes!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(item.id!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.medication_outlined, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Belum ada jadwal obat',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + untuk menambah jadwal',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
      ],
    ),
  );

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal obat ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _delete(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
