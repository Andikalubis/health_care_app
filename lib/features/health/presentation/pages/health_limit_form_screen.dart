import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/data/models/health_limit_model.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';

class HealthLimitFormScreen extends StatefulWidget {
  final HealthLimitModel? item;
  final List<HealthTypeModel> types;

  const HealthLimitFormScreen({super.key, this.item, required this.types});

  @override
  State<HealthLimitFormScreen> createState() => _HealthLimitFormScreenState();
}

class _HealthLimitFormScreenState extends State<HealthLimitFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  int? _selectedTypeId;
  late TextEditingController _warnMinCtrl;
  late TextEditingController _warnMaxCtrl;
  late TextEditingController _dangMinCtrl;
  late TextEditingController _dangMaxCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTypeId = widget.item?.healthTypeId;
    _warnMinCtrl = TextEditingController(
      text: widget.item?.warningMin?.toString(),
    );
    _warnMaxCtrl = TextEditingController(
      text: widget.item?.warningMax?.toString(),
    );
    _dangMinCtrl = TextEditingController(
      text: widget.item?.dangerMin?.toString(),
    );
    _dangMaxCtrl = TextEditingController(
      text: widget.item?.dangerMax?.toString(),
    );
  }

  @override
  void dispose() {
    _warnMinCtrl.dispose();
    _warnMaxCtrl.dispose();
    _dangMinCtrl.dispose();
    _dangMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final model = HealthLimitModel(
        healthTypeId: _selectedTypeId,
        warningMin: double.tryParse(_warnMinCtrl.text),
        warningMax: double.tryParse(_warnMaxCtrl.text),
        dangerMin: double.tryParse(_dangMinCtrl.text),
        dangerMax: double.tryParse(_dangMaxCtrl.text),
      );

      if (widget.item == null) {
        await _api.storeHealthLimit(model);
      } else {
        await _api.updateHealthLimit(widget.item!.id!, model);
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
        title: Text(isEdit ? 'Edit Batas Kesehatan' : 'Tambah Batas Kesehatan'),
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
                    DropdownButtonFormField<int>(
                      value: _selectedTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Pemeriksaan',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.types.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTypeId = val),
                      validator: (v) => v == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ambang Batas Peringatan (Warning)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _warnMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _warnMaxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ambang Batas Bahaya (Danger)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dangMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dangMaxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
