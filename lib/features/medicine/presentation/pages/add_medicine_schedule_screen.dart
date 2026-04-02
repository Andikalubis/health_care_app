import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_time_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/core/widgets/date_time_picker_field.dart';
import 'package:health_care_app/core/utils/date_format_helper.dart';

class AddMedicineScheduleScreen extends StatefulWidget {
  final MedicineScheduleModel? existing;
  const AddMedicineScheduleScreen({super.key, this.existing});

  @override
  State<AddMedicineScheduleScreen> createState() =>
      _AddMedicineScheduleScreenState();
}

class _AddMedicineScheduleScreenState extends State<AddMedicineScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  // Controllers
  final _dosageCtrl = TextEditingController();
  final _dosePerIntakeCtrl = TextEditingController(text: '1');
  final _qtyTotalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final List<TextEditingController> _timeCtrls = [];

  // Data
  bool _loading = false;
  bool _loadingData = true;
  List<PatientDataModel> _patients = [];
  List<MedicineModel> _medicines = [];

  // Form State
  int? _selectedPatientId;
  int? _selectedMedicineId;
  int _signaFreq = 1;
  String _mealRelation = 'none';
  DateTime _startDate = DateTime.now();
  int _calculatedDays = 0;
  DateTime? _calculatedEndDate;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedPatientId = e.patientId;
      _selectedMedicineId = e.medicineId;
      _signaFreq = e.signaFrequency ?? 1;
      _mealRelation = e.mealRelation ?? 'none';
      _dosageCtrl.text = e.dosage ?? '';
      _dosePerIntakeCtrl.text = e.dosePerIntake?.toString() ?? '1';
      _qtyTotalCtrl.text = e.qtyTotal?.toString() ?? '';
      _notesCtrl.text = e.notes ?? '';
      if (e.startDate != null) {
        try {
          _startDate = DateTime.parse(e.startDate!);
        } catch (_) {}
      }
      _startDateCtrl.text = _startDate.toIso8601String().split('T').first;

      List<String>? initTimes;
      if (e.scheduleTimes != null && e.scheduleTimes!.isNotEmpty) {
        initTimes = e.scheduleTimes!.map((t) => t.drinkTime ?? '').toList();
      }
      _updateTimeControllers(initTimes);
      _calculateEndDate();
    } else {
      _startDateCtrl.text = _startDate.toIso8601String().split('T').first;
      _updateTimeControllers();
    }

    // Add listeners for auto-calculation
    _dosePerIntakeCtrl.addListener(_calculateEndDate);
    _qtyTotalCtrl.addListener(_calculateEndDate);

    _loadData();
  }

  void _updateTimeControllers([List<String>? overrideTimes]) {
    // Save existing values if possible
    List<String> oldTimes =
        overrideTimes ?? _timeCtrls.map((c) => c.text).toList();

    // Clear and rebuild controllers
    for (var ctrl in _timeCtrls) {
      ctrl.dispose();
    }
    _timeCtrls.clear();

    for (int i = 0; i < _signaFreq; i++) {
      String defaultTime = '';
      if (i < oldTimes.length) {
        defaultTime = oldTimes[i];
      } else {
        // Default smart times (e.g., 08:00, 14:00, 20:00)
        int hour = 8 + (i * (16 ~/ _signaFreq));
        defaultTime = '${hour.toString().padLeft(2, '0')}:00:00';
      }
      _timeCtrls.add(TextEditingController(text: defaultTime));
    }
  }

  void _calculateEndDate() {
    double dosePerIntake = double.tryParse(_dosePerIntakeCtrl.text) ?? 0.0;
    int qtyTotal = int.tryParse(_qtyTotalCtrl.text) ?? 0;

    if (dosePerIntake <= 0 || qtyTotal <= 0 || _signaFreq <= 0) {
      setState(() {
        _calculatedDays = 0;
        _calculatedEndDate = null;
      });
      return;
    }

    double dailyConsumption = _signaFreq * dosePerIntake;
    if (dailyConsumption <= 0) dailyConsumption = 1;

    int daysLasting = (qtyTotal / dailyConsumption).ceil();

    setState(() {
      _calculatedDays = daysLasting;
      _calculatedEndDate = _startDate.add(Duration(days: daysLasting - 1));
    });
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
          if (_patients.isNotEmpty && _selectedPatientId == null) {
            _selectedPatientId = _patients.first.id;
          }
          if (_medicines.isNotEmpty && _selectedMedicineId == null) {
            _selectedMedicineId = _medicines.first.id;
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
    _dosageCtrl.dispose();
    _dosePerIntakeCtrl.dispose();
    _qtyTotalCtrl.dispose();
    _notesCtrl.dispose();
    _startDateCtrl.dispose();
    for (var ctrl in _timeCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Build schedule time models
      List<MedicineScheduleTimeModel> times = _timeCtrls.map((c) {
        return MedicineScheduleTimeModel(drinkTime: c.text);
      }).toList();

      final model = MedicineScheduleModel(
        patientId: _selectedPatientId,
        medicineId: _selectedMedicineId,
        dosage: _dosageCtrl.text.trim(),
        signaFrequency: _signaFreq,
        dosePerIntake: double.parse(_dosePerIntakeCtrl.text.trim()),
        mealRelation: _mealRelation,
        qtyTotal: int.parse(_qtyTotalCtrl.text.trim()),
        startDate: _startDate.toIso8601String().split('T').first,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        scheduleTimes: times,
      );

      if (widget.existing == null) {
        await _api.storeMedicineSchedule(model);
      } else {
        await _api.updateMedicineSchedule(widget.existing!.id!, model);
      }
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
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          try {
            final data = e.response!.data;
            if (data is Map && data['errors'] != null) {
              errorMsg = data['errors'].toString();
            } else if (data is Map && data['message'] != null) {
              errorMsg = data['message'].toString();
            } else {
              errorMsg = e.response!.data.toString();
            }
          } catch (_) {}
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $errorMsg')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Jadwal Obat' : 'Tambah Jadwal Obat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── PASIEN & OBAT ───
              Card(
                elevation: 0,
                color: Colors.blue.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_patients.isNotEmpty)
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
                      if (_medicines.isNotEmpty)
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── ATURAN PAKAI (SIGNA) ───
              const Text(
                'Aturan Pakai (Signa)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _signaFreq,
                      decoration: const InputDecoration(
                        labelText: 'Frekuensi Hari',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: [1, 2, 3, 4, 5, 6]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('${e}x Sehari'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _signaFreq = v;
                            _updateTimeControllers();
                            _calculateEndDate();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dosePerIntakeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Jumlah per Minum',
                        suffixText: 'unit',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib isi';
                        if (double.tryParse(v) == null) return 'Harus angka';
                        if (double.parse(v) <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _mealRelation,
                decoration: const InputDecoration(
                  labelText: 'Keterangan Makan',
                  prefixIcon: Icon(Icons.restaurant),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'before',
                    child: Text('Sebelum Makan'),
                  ),
                  DropdownMenuItem(
                    value: 'after',
                    child: Text('Sesudah Makan'),
                  ),
                  DropdownMenuItem(
                    value: 'with',
                    child: Text('Saat Makan (Bersamaan)'),
                  ),
                  DropdownMenuItem(
                    value: 'none',
                    child: Text('Bebas (Tidak ada aturan khusus)'),
                  ),
                ],
                onChanged: (v) => setState(() => _mealRelation = v ?? 'none'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosis Kandungan (Opsional)',
                  hintText: 'Cth: 500mg, 10ml',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 24),

              // ─── WAKTU MINUM OBAT ───
              const Text(
                'Waktu Minum',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_signaFreq, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TimePickerField(
                    controller: _timeCtrls[index],
                    label: 'Waktu Minum ke-${index + 1}',
                    prefixIcon: Icons.access_time,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Waktu wajib diisi' : null,
                  ),
                );
              }),
              const SizedBox(height: 12),

              // ─── KALKULASI STOK & TANGGAL ───
              const Text(
                'Perhitungan Stok & Tanggal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyTotalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Qty Dibawa',
                        hintText: 'Jumlah obat total',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib isi';
                        if (int.tryParse(v) == null) return 'Harus angka';
                        if (int.parse(v) <= 0) return '> 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DatePickerField(
                      controller: _startDateCtrl,
                      label: 'Tgl Mulai',
                      prefixIcon: Icons.calendar_today,
                      onChanged: (dateStr) {
                        if (dateStr.isNotEmpty) {
                          _startDate = DateTime.parse(dateStr);
                          _calculateEndDate();
                        }
                      },
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tampilan Kalkulasi Otomatis
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Estimasi Selesai',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_calculatedEndDate != null) ...[
                      Text(
                        'Obat akan habis dalam $_calculatedDays hari.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tgl Selesai: ${formatDateOnly(_calculatedEndDate!.toIso8601String())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Isi Jumlah Per Minum dan Total Qty untuk melihat estimasi.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        isEdit ? 'Perbarui Jadwal Obat' : 'Simpan Jadwal Obat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
