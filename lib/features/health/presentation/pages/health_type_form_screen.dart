import 'package:flutter/material.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';

class HealthTypeFormScreen extends StatefulWidget {
  final HealthTypeModel? item;

  const HealthTypeFormScreen({super.key, this.item});

  @override
  State<HealthTypeFormScreen> createState() => _HealthTypeFormScreenState();
}

class _HealthTypeFormScreenState extends State<HealthTypeFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _descCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name);
    _unitCtrl = TextEditingController(text: widget.item?.unit);
    _minCtrl = TextEditingController(text: widget.item?.normalMin?.toString());
    _maxCtrl = TextEditingController(text: widget.item?.normalMax?.toString());
    _descCtrl = TextEditingController(text: widget.item?.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final model = HealthTypeModel(
        name: _nameCtrl.text.trim(),
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        normalMin: double.tryParse(_minCtrl.text),
        normalMax: double.tryParse(_maxCtrl.text),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
      );

      if (widget.item == null) {
        await _api.storeHealthType(model);
      } else {
        await _api.updateHealthType(widget.item!.id!, model);
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
        title: Text(
          isEdit ? 'Edit Jenis Pemeriksaan' : 'Tambah Jenis Pemeriksaan',
        ),
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
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemeriksaan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: Tekanan Darah, Detak Jantung',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Unit Satuan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: mmHg, BPM, °C',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minimal Normal',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Maksimal Normal',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(),
                      ),
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
