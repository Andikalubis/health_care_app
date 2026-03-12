import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/meal/data/models/meal_schedule_model.dart';
import 'add_meal_schedule_screen.dart';

class MealScheduleListScreen extends StatefulWidget {
  final bool showAppBar;
  const MealScheduleListScreen({super.key, this.showAppBar = true});

  @override
  State<MealScheduleListScreen> createState() => _MealScheduleListScreenState();
}

class _MealScheduleListScreenState extends State<MealScheduleListScreen> {
  final _api = ApiService();
  List<MealScheduleModel> _items = [];
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
      final data = await _api.getMealSchedules();
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
      await _api.deleteMealSchedule(id);
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
              title: const Text('Jadwal Makan'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMealScheduleScreen()),
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

  Widget _buildCard(MealScheduleModel item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.15),
          child: const Icon(Icons.restaurant, color: Colors.orangeAccent),
        ),
        title: Text(
          item.mealType?.name ?? 'Jadwal Makan #${item.id}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.mealTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(item.mealTime!, style: const TextStyle(fontSize: 15)),
                ],
              ),
            if (item.notes != null)
              Text(item.notes!, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(item.id!),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Belum ada jadwal makan',
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
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal makan ini akan dihapus.'),
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
