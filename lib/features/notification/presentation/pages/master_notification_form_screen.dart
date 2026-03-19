import 'package:flutter/material.dart';
import 'package:health_care_app/features/notification/data/models/master_notification_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';

class MasterNotificationFormScreen extends StatefulWidget {
  final MasterNotificationModel? item;

  const MasterNotificationFormScreen({super.key, this.item});

  @override
  State<MasterNotificationFormScreen> createState() =>
      _MasterNotificationFormScreenState();
}

class _MasterNotificationFormScreenState
    extends State<MasterNotificationFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _messageCtrl;
  String? _selectedType;

  bool _isLoading = false;

  final List<String> _types = [
    'general',
    'medical',
    'system',
    'alert',
    'reminder',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item?.title);
    _messageCtrl = TextEditingController(text: widget.item?.message);
    _selectedType = widget.item?.notificationType ?? 'general';
    if (!_types.contains(_selectedType)) {
      _selectedType = 'general'; // fallback
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final model = MasterNotificationModel(
        title: _titleCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
        notificationType: _selectedType,
      );

      if (widget.item == null) {
        await _api.storeMasterNotification(model);
      } else {
        await _api.updateMasterNotification(widget.item!.id!, model);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Notifikasi' : 'Tambah Notifikasi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Pesan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipe Notifikasi',
                        border: OutlineInputBorder(),
                      ),
                      items: _types.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedType = val);
                      },
                      validator: (v) => v == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 32),
                    // "tolong juga untuk memperkecil ukuran setiap buttonya jangan terlalu besar"
                    Center(
                      child: IntrinsicWidth(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Simpan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
