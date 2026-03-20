import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/health/data/models/health_limit_model.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/presentation/pages/health_limit_form_screen.dart';

class HealthLimitListScreen extends StatefulWidget {
  const HealthLimitListScreen({super.key});

  @override
  State<HealthLimitListScreen> createState() => _HealthLimitListScreenState();
}

class _HealthLimitListScreenState extends State<HealthLimitListScreen> {
  final _api = ApiService();
  List<HealthLimitModel> _limits = [];
  List<HealthTypeModel> _types = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _api.getHealthLimits(),
        _api.getHealthTypes(),
      ]);
      setState(() {
        _limits = futures[0] as List<HealthLimitModel>;
        _types = futures[1] as List<HealthTypeModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getTypeName(int? id) {
    if (id == null) return '-';
    try {
      return _types.firstWhere((t) => t.id == id).name;
    } catch (_) {
      return 'ID: $id';
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _api.deleteHealthLimit(id);
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
          content: const Text('Yakin ingin menghapus batas kesehatan ini?'),
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
      appBar: AppBar(title: const Text('Batas Kesehatan'), centerTitle: true),
      body: _isLoading
          ? const AppListSkeleton()
          : _limits.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _limits.length,
                itemBuilder: (context, index) {
                  final item = _limits[index];
                  return _buildCard(item, theme);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HealthLimitFormScreen(types: _types),
            ),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(HealthLimitModel item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.assignment_late_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          _getTypeName(item.healthTypeId),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Warning: ${item.warningMin ?? '-'} to ${item.warningMax ?? '-'}',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
            Text(
              'Danger: ${item.dangerMin ?? '-'} to ${item.dangerMax ?? '-'}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
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
                    builder: (_) =>
                        HealthLimitFormScreen(item: item, types: _types),
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
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada batas kesehatan',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
