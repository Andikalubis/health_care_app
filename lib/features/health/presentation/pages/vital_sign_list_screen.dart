import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'add_vital_sign_screen.dart';

class VitalSignListScreen extends StatefulWidget {
  final bool showAppBar;
  const VitalSignListScreen({super.key, this.showAppBar = true});

  @override
  State<VitalSignListScreen> createState() => _VitalSignListScreenState();
}

class _VitalSignListScreenState extends State<VitalSignListScreen> {
  final _api = ApiService();
  List<VitalSignModel> _items = [];
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

      final data = await _api.getVitalSigns();
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
      await _api.deleteVitalSign(id);
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
              title: const Text('Tanda Vital'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            )
          : null,
      floatingActionButton: _userRole == 'admin'
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddVitalSignScreen()),
                );
                if (result == true) _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
      body: _loading
          ? const AppListSkeleton()
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
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

  Widget _buildEmpty() {
    return Center(
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
            'Belum ada data tanda vital',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(VitalSignModel item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.checkTime ?? item.createdAt ?? '-',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_userRole != 'admin')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(item.id!),
                  ),
              ],
            ),
            const Divider(),
            _row(
              Icons.favorite,
              'Detak Jantung',
              '${item.heartRate ?? '-'} BPM',
              Colors.redAccent,
            ),
            _row(
              Icons.speed,
              'Tekanan Darah',
              item.bloodPressure ?? '-',
              Colors.blueAccent,
            ),
            _row(
              Icons.thermostat,
              'Suhu Tubuh',
              '${item.bodyTemperature ?? '-'} °C',
              Colors.orange,
            ),
            _row(
              Icons.air,
              'Laju Pernapasan',
              '${item.breathingRate ?? '-'} /menit',
              Colors.teal,
            ),
            _row(
              Icons.bloodtype,
              'Saturasi O₂',
              '${item.oxygenLevel ?? '-'}%',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text('Data tanda vital ini akan dihapus permanen.'),
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
