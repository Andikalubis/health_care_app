import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_history_model.dart';
import 'package:health_care_app/features/medicine/presentation/pages/medicine_history_detail_screen.dart';

class MedicineHistoryListScreen extends StatefulWidget {
  const MedicineHistoryListScreen({super.key});

  @override
  State<MedicineHistoryListScreen> createState() =>
      _MedicineHistoryListScreenState();
}

class _MedicineHistoryListScreenState extends State<MedicineHistoryListScreen> {
  final _api = ApiService();
  List<MedicineHistoryModel> _items = [];
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
      final data = await _api.getMedicineHistories();
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
      await _api.deleteMedicineHistory(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Minum Obat'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const AppListSkeleton()
          : _error != null
          ? _buildError()
          : _items.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (_, i) => _buildCard(_items[i], theme),
              ),
            ),
    );
  }

  Widget _buildCard(MedicineHistoryModel item, ThemeData theme) {
    final color = _getStatusColor(item.status);
    final med = item.medicineSchedule?.medicine;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicineHistoryDetailScreen(history: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(_getStatusIcon(item.status), color: color),
          ),
          title: Text(
            med?.name ?? 'Riwayat Dosis #${item.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Status: ${_getStatusText(item.status)}'),
              const SizedBox(height: 4),
              Text(
                formatDateTimeShort(item.takenTime ?? item.createdAt ?? ''),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(item.id!),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus riwayat dosis ini?',
        ),
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

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_edu, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Tidak ada riwayat',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
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
}
