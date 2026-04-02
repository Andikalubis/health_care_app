import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/data/models/health_alert_model.dart';
import 'package:health_care_app/features/health/presentation/pages/health_alert_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthAlertListScreen extends StatefulWidget {
  final bool showAppBar;
  const HealthAlertListScreen({super.key, this.showAppBar = true});

  @override
  State<HealthAlertListScreen> createState() => _HealthAlertListScreenState();
}

class _HealthAlertListScreenState extends State<HealthAlertListScreen> {
  final _api = ApiService();
  List<HealthAlertModel> _items = [];
  bool _loading = true;
  String? _error;
  String _userRole = 'user';

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
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('user_role') ?? 'user';

      final data = await _api.getHealthAlerts();
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
      await _api.deleteHealthAlert(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Peringatan Kesehatan'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            )
          : null,
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

  Widget _buildCard(HealthAlertModel item, ThemeData theme) {
    final color = _getLevelColor(item.alertLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HealthAlertDetailScreen(alert: item),
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
            child: Icon(_getLevelIcon(item.alertLevel), color: color),
          ),
          title: Text(
            item.healthCheck?.patient?.name ?? 'Peringatan #${item.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.message ?? 'Tidak ada pesan.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                formatDateTimeShort(item.createdAt ?? ''),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          trailing: _userRole == 'admin'
              ? null
              : IconButton(
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
        title: const Text('Hapus Peringatan?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus peringatan ini?',
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
        Icon(
          Icons.monitor_heart_outlined,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak ada peringatan',
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
