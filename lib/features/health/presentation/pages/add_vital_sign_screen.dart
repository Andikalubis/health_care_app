import 'package:flutter/material.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/core/widgets/date_time_picker_field.dart';

class AddVitalSignScreen extends StatefulWidget {
  final VitalSignModel? existing;
  const AddVitalSignScreen({super.key, this.existing});

  @override
  State<AddVitalSignScreen> createState() => _AddVitalSignScreenState();
}

class _AddVitalSignScreenState extends State<AddVitalSignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _bloodPressureCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _breathingCtrl = TextEditingController();
  final _oxygenCtrl = TextEditingController();
  final _checkTimeCtrl = TextEditingController();

  bool _loading = false;
  List<PatientDataModel> _patients = [];
  int? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    // Default check_time to now
    _checkTimeCtrl.text = DateTime.now().toIso8601String().substring(0, 19);
    _loadPatients();
    if (widget.existing != null) {
      final e = widget.existing!;
      _bloodPressureCtrl.text = e.bloodPressure ?? '';
      _heartRateCtrl.text = e.heartRate?.toString() ?? '';
      _tempCtrl.text = e.bodyTemperature?.toString() ?? '';
      _breathingCtrl.text = e.breathingRate?.toString() ?? '';
      _oxygenCtrl.text = e.oxygenLevel?.toString() ?? '';
      if (e.checkTime != null) _checkTimeCtrl.text = e.checkTime!;
    }
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _api.getPatientData();
      if (mounted) {
        setState(() {
          _patients = patients;
          if (_patients.isNotEmpty && widget.existing == null) {
            _selectedPatientId = _patients.first.id;
          } else if (widget.existing != null) {
            _selectedPatientId = widget.existing!.patientId;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _bloodPressureCtrl.dispose();
    _heartRateCtrl.dispose();
    _tempCtrl.dispose();
    _breathingCtrl.dispose();
    _oxygenCtrl.dispose();
    _checkTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final model = VitalSignModel(
        patientId: _selectedPatientId,
        bloodPressure: _bloodPressureCtrl.text.trim(),
        heartRate: int.tryParse(_heartRateCtrl.text.trim()),
        bodyTemperature: double.tryParse(_tempCtrl.text.trim()),
        breathingRate: int.tryParse(_breathingCtrl.text.trim()),
        oxygenLevel: double.tryParse(_oxygenCtrl.text.trim()),
        checkTime: _checkTimeCtrl.text.trim(),
      );
      if (widget.existing != null) {
        await _api.updateVitalSign(widget.existing!.id!, model);
      } else {
        await _api.storeVitalSign(model);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tanda vital disimpan!'),
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
      appBar: AppBar(
        title: Text(
          widget.existing != null ? 'Edit Tanda Vital' : 'Tambah Tanda Vital',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_patients.isNotEmpty) ...[
                const Text(
                  'Pasien',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedPatientId,
                  decoration: const InputDecoration(labelText: 'Pilih Pasien'),
                  items: _patients
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                  validator: (v) => v == null ? 'Pilih pasien' : null,
                ),
                const SizedBox(height: 16),
              ],
              _field(
                _bloodPressureCtrl,
                'Tekanan Darah',
                'contoh: 120/80',
                icon: Icons.speed,
              ),
              _numField(_heartRateCtrl, 'Detak Jantung (BPM)', Icons.favorite),
              _numField(
                _tempCtrl,
                'Suhu Tubuh (°C)',
                Icons.thermostat,
                isDecimal: true,
              ),
              _numField(_breathingCtrl, 'Laju Pernapasan (/menit)', Icons.air),
              _numField(
                _oxygenCtrl,
                'Saturasi O₂ (%)',
                Icons.bloodtype,
                isDecimal: true,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DateTimePickerField(
                  controller: _checkTimeCtrl,
                  label: 'Waktu Pengukuran',
                  prefixIcon: Icons.event,
                  lastDate: DateTime.now().add(const Duration(minutes: 5)),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Waktu wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return '$label wajib diisi';
          if (label == 'Tekanan Darah' && !RegExp(r'^\d+\/\d+$').hasMatch(v)) {
            return 'Format tidak valid (cth: 120/80)';
          }
          return null;
        },
      ),
    );
  }

  Widget _numField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (v) {
          if (v == null || v.isEmpty) return '$label wajib diisi';
          if (double.tryParse(v) == null) return 'Masukkan angka yang valid';
          return null;
        },
      ),
    );
  }
}
