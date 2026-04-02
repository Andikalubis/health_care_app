import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/meal/data/models/meal_schedule_model.dart';
import 'package:health_care_app/features/meal/data/models/meal_type_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/core/widgets/date_time_picker_field.dart';

class AddMealScheduleScreen extends StatefulWidget {
  final MealScheduleModel? existing;
  const AddMealScheduleScreen({super.key, this.existing});

  @override
  State<AddMealScheduleScreen> createState() => _AddMealScheduleScreenState();
}

class _AddMealScheduleScreenState extends State<AddMealScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _mealTimeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _loading = false;
  bool _loadingData = true;
  List<PatientDataModel> _patients = [];
  List<MealTypeModel> _mealTypes = [];
  int? _selectedPatientId;
  int? _selectedMealTypeId;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedPatientId = e.patientId;
      _selectedMealTypeId = e.mealTypeId;
      _mealTimeCtrl.text = e.mealTime ?? '';
      _notesCtrl.text = e.notes ?? '';
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.getPatientData(),
        _api.getMealTypes(),
      ]);
      if (mounted) {
        setState(() {
          _patients = results[0] as List<PatientDataModel>;
          _mealTypes = results[1] as List<MealTypeModel>;
          if (widget.existing == null) {
            if (_patients.isNotEmpty && _selectedPatientId == null) {
              _selectedPatientId = _patients.first.id;
            }
            if (_mealTypes.isNotEmpty && _selectedMealTypeId == null) {
              _selectedMealTypeId = _mealTypes.first.id;
            }
          }
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _mealTimeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final model = MealScheduleModel(
        patientId: _selectedPatientId,
        mealTypeId: _selectedMealTypeId,
        mealTime: _mealTimeCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (widget.existing == null) {
        await _api.storeMealSchedule(model);
      } else {
        await _api.updateMealSchedule(widget.existing!.id!, model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal makan disimpan!'),
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
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Jadwal Makan' : 'Tambah Jadwal Makan'),
      ),
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
                    if (_mealTypes.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        initialValue: _selectedMealTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Waktu Makan',
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        items: _mealTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedMealTypeId = v),
                        validator: (v) =>
                            v == null ? 'Pilih jenis makan' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // TimePickerField stores value as HH:mm:00 (24-hr, API-ready)
                    TimePickerField(
                      controller: _mealTimeCtrl,
                      label: 'Waktu Makan',
                      prefixIcon: Icons.access_time,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Waktu wajib diisi' : null,
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
                          : Text(
                              isEdit
                                  ? 'Perbarui Jadwal Makan'
                                  : 'Simpan Jadwal Makan',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
