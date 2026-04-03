import 'package:flutter/material.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/core/services/reverb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/health/presentation/pages/health_check_detail_screen.dart';
import 'add_health_check_screen.dart';

class HealthCheckListScreen extends StatefulWidget {
  final bool showAppBar;
  const HealthCheckListScreen({super.key, this.showAppBar = true});

  @override
  State<HealthCheckListScreen> createState() => _HealthCheckListScreenState();
}

class _HealthCheckListScreenState extends State<HealthCheckListScreen> {
  final _api = ApiService();
  List<HealthCheckModel> _items = [];
  bool _loading = true;
  String? _error;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _load();
    _initRealtime();
  }

  void _initRealtime() async {
    final realtime = ReverbService();
    await realtime.init();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      realtime.subscribePrivate('patient.$userId', 'health.check.updated', (_) {
        Future.delayed(const Duration(seconds: 1), () => _load());
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString('user_role') ?? 'user';

      final data = await _api.getHealthChecks();
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
      await _api.deleteHealthCheck(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'danger':
        return Icons.dangerous;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'danger':
        return 'Bahaya';
      case 'warning':
        return 'Peringatan';
      default:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Pemeriksaan Kesehatan'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            )
          : null,
      floatingActionButton: _userRole == 'admin'
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddHealthCheckScreen(),
                  ),
                );
                if (ok == true) _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
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

  Widget _buildCard(HealthCheckModel item, ThemeData theme) {
    final color = _statusColor(item.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HealthCheckDetailScreen(check: item, userRole: _userRole),
            ),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(_statusIcon(item.status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.healthType?.name ?? 'Pemeriksaan #${item.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusLabel(item.status),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hasil: ${item.resultValue ?? '-'} ${item.healthType?.unit ?? ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Text(
                        item.notes!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatDateTimeShort(
                              item.checkTime ?? item.createdAt,
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_userRole != 'admin') ...[
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 18,
                              ),
                              onPressed: () async {
                                final ok = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddHealthCheckScreen(existing: item),
                                  ),
                                );
                                if (ok == true) _load();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () => _confirmDelete(item.id!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.health_and_safety_outlined,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Belum ada data pemeriksaan',
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

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text('Data pemeriksaan ini akan dihapus.'),
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
