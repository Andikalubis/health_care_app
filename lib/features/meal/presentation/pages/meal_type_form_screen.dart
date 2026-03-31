import 'package:flutter/material.dart';
import 'package:health_care_app/features/meal/data/models/meal_type_model.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';

class MealTypeFormScreen extends StatefulWidget {
  final MealTypeModel? item;

  const MealTypeFormScreen({super.key, this.item});

  @override
  State<MealTypeFormScreen> createState() => _MealTypeFormScreenState();
}

class _MealTypeFormScreenState extends State<MealTypeFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final model = MealTypeModel(name: _nameCtrl.text.trim());

      if (widget.item == null) {
        await _api.storeMealType(model);
      } else {
        await _api.updateMealType(widget.item!.id!, model);
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
        title: Text(isEdit ? 'Edit Jenis Makanan' : 'Tambah Jenis Makanan'),
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
                        labelText: 'Nama Jenis Makanan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: Makan Pagi, Makan Siang',
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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
