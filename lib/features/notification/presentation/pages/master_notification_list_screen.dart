import 'package:flutter/material.dart';
import 'package:health_care_app/core/widgets/app_list_skeleton.dart';
import 'package:health_care_app/features/notification/data/models/master_notification_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/notification/presentation/pages/master_notification_form_screen.dart';

class MasterNotificationListScreen extends StatefulWidget {
  const MasterNotificationListScreen({super.key});

  @override
  State<MasterNotificationListScreen> createState() =>
      _MasterNotificationListScreenState();
}

class _MasterNotificationListScreenState
    extends State<MasterNotificationListScreen> {
  final _api = ApiService();
  List<MasterNotificationModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getMasterNotifications();
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
      await _api.deleteMasterNotification(id);
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
          content: const Text('Yakin ingin menghapus notifikasi ini?'),
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
      appBar: AppBar(title: const Text('Master Notifikasi'), centerTitle: true),
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
            MaterialPageRoute(
              builder: (_) => const MasterNotificationFormScreen(),
            ),
          );
          if (res == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(MasterNotificationModel item, ThemeData theme) {
    final typeStr = item.notificationType ?? 'general';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          item.title ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.message ?? '-'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeStr.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
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
                    builder: (_) => MasterNotificationFormScreen(item: item),
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
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
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
