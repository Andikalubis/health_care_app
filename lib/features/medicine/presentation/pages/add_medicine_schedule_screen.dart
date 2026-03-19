import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class AddMedicineScheduleScreen extends StatefulWidget {
  const AddMedicineScheduleScreen({super.key});

  @override
  State<AddMedicineScheduleScreen> createState() =>
      _AddMedicineScheduleScreenState();
}

class _AddMedicineScheduleScreenState extends State<AddMedicineScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _dosageCtrl = TextEditingController();
  final _drinkTimeCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _loading = false;
  bool _loadingData = true;
  List<PatientDataModel> _patients = [];
  List<MedicineModel> _medicines = [];
  int? _selectedPatientId;
  int? _selectedMedicineId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.getPatientData(),
        _api.getMedicines(),
      ]);
      if (mounted) {
        setState(() {
          _patients = results[0] as List<PatientDataModel>;
          _medicines = results[1] as List<MedicineModel>;
          if (_patients.isNotEmpty) {
            _selectedPatientId = _patients.first.id;
          }
          if (_medicines.isNotEmpty) {
            _selectedMedicineId = _medicines.first.id;
          }
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _dosageCtrl.dispose();
    _drinkTimeCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) ctrl.text = picked.toIso8601String().split('T').first;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _drinkTimeCtrl.text = picked.format(context);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final model = MedicineScheduleModel(
        patientId: _selectedPatientId,
        medicineId: _selectedMedicineId,
        dosage: _dosageCtrl.text.trim(),
        drinkTime: _drinkTimeCtrl.text.trim(),
        startDate: _startDateCtrl.text.trim().isEmpty
            ? null
            : _startDateCtrl.text.trim(),
        endDate: _endDateCtrl.text.trim().isEmpty
            ? null
            : _endDateCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await _api.storeMedicineSchedule(model);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal obat disimpan!'),
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
      appBar: AppBar(title: const Text('Tambah Jadwal Obat')),
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
                    if (_medicines.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        initialValue: _selectedMedicineId,
                        decoration: const InputDecoration(
                          labelText: 'Obat',
                          prefixIcon: Icon(Icons.medication),
                        ),
                        items: _medicines
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedMedicineId = v),
                        validator: (v) => v == null ? 'Pilih obat' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _dosageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dosis',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Dosis wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _drinkTimeCtrl,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Waktu Minum',
                        prefixIcon: Icon(Icons.access_time),
                        suffixIcon: Icon(Icons.chevron_right),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Waktu wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startDateCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(_startDateCtrl),
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.chevron_right),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Tanggal mulai wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endDateCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(_endDateCtrl),
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Selesai',
                        prefixIcon: Icon(Icons.calendar_month),
                        suffixIcon: Icon(Icons.chevron_right),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Tanggal selesai wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
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
                          : const Text('Simpan Jadwal Obat'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
