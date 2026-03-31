import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/presentation/pages/health_type_form_screen.dart';

class HealthTypeListScreen extends StatefulWidget {
  const HealthTypeListScreen({super.key});

  @override
  State<HealthTypeListScreen> createState() => _HealthTypeListScreenState();
}

class _HealthTypeListScreenState extends State<HealthTypeListScreen> {
  final _api = ApiService();
  List<HealthTypeModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getHealthTypes();
      setState(() => _items = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
        setState(() => _items = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _api.deleteHealthType(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: const Text('Yakin ingin menghapus jenis pemeriksaan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteItem(id);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Jenis Pemeriksaan'), centerTitle: true),
      body: _isLoading
          ? const AppListSkeleton()
          : _items.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _buildCard(item, theme);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HealthTypeFormScreen()),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(HealthTypeModel item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.health_and_safety_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Unit: ${item.unit ?? '-'}'),
            if (item.normalMin != null || item.normalMax != null)
              Text(
                'Normal: ${item.normalMin ?? '0'} - ${item.normalMax ?? '∞'}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthTypeFormScreen(item: item),
                  ),
                );
                if (res == true) _loadData();
              },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.health_and_safety_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada data',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
