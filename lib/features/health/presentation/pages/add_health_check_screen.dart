import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/health/data/models/health_limit_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class AddHealthCheckScreen extends StatefulWidget {
  const AddHealthCheckScreen({super.key});

  @override
  State<AddHealthCheckScreen> createState() => _AddHealthCheckScreenState();
}

class _AddHealthCheckScreenState extends State<AddHealthCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _valueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _loading = false;
  bool _loadingData = true;
  List<PatientDataModel> _patients = [];
  List<HealthTypeModel> _healthTypes = [];
  List<HealthLimitModel> _limits = [];
  int? _selectedPatientId;
  int? _selectedHealthTypeId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.getPatientData(),
        _api.getHealthTypes(),
        _api.getHealthLimits(),
      ]);
      if (mounted) {
        setState(() {
          _patients = results[0] as List<PatientDataModel>;
          _healthTypes = results[1] as List<HealthTypeModel>;
          _limits = results[2] as List<HealthLimitModel>;
          if (_patients.isNotEmpty) {
            _selectedPatientId = _patients.first.id;
          }
          if (_healthTypes.isNotEmpty) {
            _selectedHealthTypeId = _healthTypes.first.id;
          }
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingData = false);
      }
    }
  }

  String _calculateStatus(double val, int? typeId) {
    if (typeId == null) return 'normal';
    final limit = _limits.cast<HealthLimitModel?>().firstWhere(
      (l) => l?.healthTypeId == typeId,
      orElse: () => null,
    );
    if (limit == null) return 'normal';

    if (limit.dangerMin != null && val <= limit.dangerMin!) return 'danger';
    if (limit.dangerMax != null && val >= limit.dangerMax!) return 'danger';
    if (limit.warningMin != null && val <= limit.warningMin!) return 'warning';
    if (limit.warningMax != null && val >= limit.warningMax!) return 'warning';

    return 'normal';
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final resVal = double.tryParse(_valueCtrl.text.trim()) ?? 0;
      final model = HealthCheckModel(
        patientId: _selectedPatientId,
        healthTypeId: _selectedHealthTypeId,
        resultValue: resVal,
        status: _calculateStatus(resVal, _selectedHealthTypeId),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        checkTime: DateTime.now().toIso8601String(),
      );
      await _api.storeHealthCheck(model);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemeriksaan disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pemeriksaan')),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_patients.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        initialValue: _selectedPatientId,
                        decoration: const InputDecoration(
                          labelText: 'Pasien',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _patients
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPatientId = v),
                        validator: (v) => v == null ? 'Pilih pasien' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_healthTypes.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        initialValue: _selectedHealthTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Pemeriksaan',
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items: _healthTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedHealthTypeId = v),
                        validator: (v) => v == null ? 'Pilih jenis' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _valueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nilai Hasil',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Hasil wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Pemeriksaan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
